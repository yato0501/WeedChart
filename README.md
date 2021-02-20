# WeedChart

## Prerequisite
* Nodejs  14.15.1
* npm 6.14.7
* docker
* visual studio 2019
* angular cli 11.2.1 or higher


## How to run with docker

1.  Using powershell or other CLI tool, navigate to the dockerfile.
2.  run `docker build -t weedchart .`  
NOTE:  DO NOT FORGET THE "." AT THE END OF THE COMMAND.
3. run `docker run -p 8001:80 -d weedchart`
4. navigate to `http://localhost:8001`