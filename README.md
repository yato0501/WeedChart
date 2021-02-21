# WeedChart

## Prerequisite
* Nodejs  14.15.1
* npm 6.14.7
* docker
* visual studio 2019
* angular cli 11.2.1 or higher
* terraform cli (currently on [v0.14.7](https://releases.hashicorp.com/terraform/0.14.7/))
* aws cli [2.1.27](https://awscli.amazonaws.com/AWSCLIV2-2.1.27.msi)



## How to run with docker

1.  Using powershell or other CLI tool, navigate to the dockerfile.
2.  run `docker build -t weedchart .`  
NOTE:  DO NOT FORGET THE "." AT THE END OF THE COMMAND.
3. run `docker run -p 8001:80 -d weedchart`
4. navigate to `http://localhost:8001`


## How to push terraform

1.  Make sure you have an aws credentials file setup.
2.  in the terraform directory, run command `terraform plan` to make sure you don't have any unwanted changes.
3.  run `terraform apply` to apply changes to infrastructure.