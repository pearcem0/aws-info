# aws-info

# about aws-info
* Quickly get information about your AWS accounts
* List configured AWS profiles
* Get Account ID for specific profile
* Get information about EC2 instances by public IP or instance ID

# prerequisites & assumptions
* You have installed and configured awscli (used for describe-instances api calls etc.)

# usage
* Available options:
  * -i <public IP> find by public ip
  * -n <instance name> find by instance name
  * -p list configured aws profiles
  * -a <profile name> find account id for configured aws profile

# disclaimer
* For personal use and development - may not work for you, but feel free adapt as necessary

# Ideas
* Extend for other services
