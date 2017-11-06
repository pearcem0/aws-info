#!/bin/bash

function findbypublicip {
  publicip=$1
  resultfile=result_file.txt
  aws ec2 --profile $profile describe-instances --filters "Name=ip-address,Values=$publicip" --output table > $resultfile
  numberoflines=`wc -l $resultfile | sed 's/[^0-9]*//g'`
  if (( $numberoflines > 4  )); then
    account=`getaccountid $profile`
    echo "Profile: $profile" 
    echo "Account ID: $account"
    cat $resultfile
  else echo "Nothing found here."
  fi

  rm $resultfile
}

function findbyinstancename {
  instancename=$1
  resultfile=result_file.txt
  aws ec2 --profile $profile describe-instances --filters "Name=tag:Name,Values=$instancename" --output table > $resultfile
  numberoflines=`wc -l $resultfile | sed 's/[^0-9]*//g'`
  if (( $numberoflines > 4  )); then
    account=`getaccountid $profile`
    echo "Profile: $profile"
    echo "Account ID: $account"
    cat $resultfile
  else echo "Nothing found here."
  fi

  rm $resultfile
}


function findbyinstanceid {
  instanceid=$1
  resultfile=result_file.txt
  aws ec2 --profile $profile describe-instances --filters "Name=instance-id,Values=$instanceid" --output table > $resultfile
  numberoflines=`wc -l $resultfile | sed 's/[^0-9]*//g'`
  if (( $numberoflines > 4  )); then
    account=`getaccountid $profile`
    echo "Profile: $profile"
    echo "Account ID: $account"
    cat $resultfile
  else echo "Nothing found here."
  fi

  rm $resultfile
}

function printprofiles {
  sudo cat ~/.aws/config | grep profile | cut -d " " -f 2 | sed 's/]//g'
}

function profilewithaccountid {
  profile=$1
  account=`getaccountid $profile`
  echo "Profile: $profile; Account ID: $account"
}

function getaccountid {
  profile=$1
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

while getopts ":i:d:n:pa:" opt; do
  case $opt in
    i)
      selectedfunction="findbypublicip $OPTARG"
    ;;
    n)
      selectedfunction="findbyinstancename $OPTARG"
    ;;
    d)
      selectedfunction="findbyinstanceid $OPTARG"
    ;;
    p)
     selectedfunction="profilewithaccountid \$profile"
     # printprofiles
     # exit 0;
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

if [ $OPTIND -eq 1 ]; then echo "No options were passed. Help - available options:
    -i <public IP> find by public ip
    -n <instance name> find by instance name
    -p list configured aws profiles
    -a <profile name> find account id for configured aws profile"
      exit 0;
fi

# main function - loop through profiles to find what you are looking for
profile_list=`printprofiles`
for profile in $profile_list; do
  echo "Checking in the account profile: $profile"
  eval $selectedfunction
done
