# Procedure

## Ask Agustin for the following:

* Access to mido azure tenant
* Account on the Staging hub


## Create Device on hub

https://staging.ci.midocloud.net/

* Click '+' on bottom right corner --> add new Device
* Name = whatevs, Device type = linux, rest doesn't matter
* Click on your device to see it's settings


# Install prerequisites

sudo apt install docker.io azure-cli xclip jq 


# Create directory

mkdir mido && cd mido


# Clone mido nuttx-external repo and make

git clone https://github.com/midokura/nuttx-external.git
cd nuttx-external/evp_agent/linux
make


# Generate private key

cd ../test/tests
./simplest-cert.sh
xclip -i cert.pem
* In your browser:
	* 'Manage Credentials'
	* Credentials type: X.509 Certificate
	* Paste your key in the field below
	* Save


curl -o ../test/tests/root-ca.pem "https://staging.ci.midocloud.net/showmecacert"
az login
source <(az acr login -n midokura --expose-token |  jq -r '. | "DOCKER_USER=00000000-0000-0000-0000-000000000000; DOCKER_PASSWORD=\"" + .accessToken + "\"; DOCKER_REGISTRY=" + .loginServer + "; export DOCKER_USER; export DOCKER_PASSWORD; export DOCKER_REGISTRY"')
env | grep DOCKER_
./run2.sh mqtt-staging.ci.midocloud.net 8883 ../test/tests/{root-ca,cert,key}.pem


060f8f00-bef5-11eb-a93c-e79f75202e04
