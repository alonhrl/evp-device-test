# Procedure

### Ask Agustin for the following:

* Access to mido azure tenant
* Account on the Staging hub
* Access to the mido github


### Create Device on hub

In your browser:
* Go to: https://staging.ci.midocloud.net/
* Click '+' on bottom right corner --> add new Device
* Name = whatevs, Device type = linux, rest doesn't matter
* Click on your device to see it's settings


### Install prerequisites

```
sudo apt install docker.io azure-cli xclip jq 
```


### Clone mido nuttx-external repo and make

```
git clone https://github.com/midokura/nuttx-external.git
cd nuttx-external/evp_agent/linux
make build_with_docker
```


### Generate private key

```
cd ../test/tests
./simplest-cert.sh
xclip -i cert.pem
```
In your browser:
* 'Manage Credentials'
* Credentials type: X.509 Certificate
* Paste your key in the field below (middle click)
* Save


### Run EVP Agent

``` 
cd ../../linux
curl -o ../test/tests/root-ca.pem "https://staging.ci.midocloud.net/showmecacert"
az login
```
Login to your azure account
```
source <(az acr login -n midokura --expose-token |  jq -r '. | "DOCKER_USER=00000000-0000-0000-0000-000000000000; DOCKER_PASSWORD=\"" + .accessToken + "\"; DOCKER_REGISTRY=" + .loginServer + "; export DOCKER_USER; export DOCKER_PASSWORD; export DOCKER_REGISTRY"')
env | grep DOCKER_
./run2.sh mqtt-staging.ci.midocloud.net 8883 ../test/tests/{root-ca,cert,key}.pem
```


### EVP Rest Api

In your browser:
* In the thingsboard UI, copy your device ID
* Paste it in 'entity_type_ids.txt'

Input your credentials in 'staging_credentials'

Open a new terminal tab to the root of this repo and run:

```
. quick-get-token.sh
```

Cope the token

In your browser:
* Open a new tab to https://staging.ci.midocloud.net/swagger-ui.html#
* On the top right, click on 'Authorize'
* In the 'value' field enter: Bearer <token>


