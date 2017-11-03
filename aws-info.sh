#!/bin/bash

function findbypublicip {
  publicip=$1
  resultfile=result_file_$profile.txt
  aws ec2 --profile $profile describe-instances --filters "Name=ip-address,Values=$publicip" --output table > $resultfile
  numberoflines=`wc -l $resultfile | sed 's/[^0-9]*//g'`
  if (( $numberoflines > 4  )); then
    echo "Profile: $profile" && cat $resultfile
  else echo "Nothing found here."
  fi

}

function findbyinstancename {
  instancename=$1
  resultfile=result_file.txt
  aws ec2 --profile $profile describe-instances --filters "Name=tag:Name,Values=$instancename" --output table > $resultfile
  numberoflines=`wc -l $resultfile | sed 's/[^0-9]*//g'`
  if (( $numberoflines > 4  )); then
    echo "Profile: $profile" && cat $resultfile
  else echo "Nothing found here."
  fi
}

function printprofiles {
  sudo cat ~/.aws/config | grep profile | cut -d " " -f 2 | sed 's/]//g'
}

function getaccountid {
  profile=$1
  resultfile=result_file.txt
  aws --profile $profile sts get-caller-identity --output text --query 'Account'
}

if [ $OPTIND -lt 1 ]; then
  echo "No options were passed.
  Help - available options:
    -i <public IP> find by public ip
    -n <instance name> find by instance name
    -p list configured aws profiles
  -a <profile name> find account id for configured aws profile"
  exit 0;
fi

while getopts ":i:n:pa:" opt; do
  case $opt in
    i)
      selectedfunction="findbypublicip $OPTARG"
    ;;
    n)
      selectedfunction="findbyinstancename $OPTARG"
    ;;
    p)
      echo "To print a list of AWS profiles that are configured, you will be asked for your sudo password"
      printprofiles
      exit 0;
    ;;
    a)
      getaccountid $OPTARG
      exit 0;
    ;;
    *)
      echo "Help - available options:
    -i <public IP> find by public ip
    -n <instance name> find by instance name
    -p list configured aws profiles
      -a <profile name> find account id for configured aws profile"
      exit 0;
    ;;
  esac
done

# main function - loop through profiles to find what you are looking for

if [ $OPTIND -eq 1 ]; then echo "No options were passed. Help - available options:
    -i <public IP> find by public ip
    -n <instance name> find by instance name
    -p list configured aws profiles
      -a <profile name> find account id for configured aws profile"
      exit 0;
fi

profile_list=`printprofiles`
for profile in $profile_list; do
  $selectedfunction
done
