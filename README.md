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
* In the 'value' field, enter: Bearer \<token\>

Setup a module (this demo will use the rpc module):
* Under evp-module-controller
* In the ```POST /api/evp/v1/module``` endpoint
* Insert the parameter:
```
{
  "name": "<insert module name>",
  "type": "linux",
  "resourceUrl": "midokura.azurecr.io/evp-module-rpc:latest",
  "entryPoint": "main",
  "hash": "00000000"
}
```
* Click 'Try it out!'
* Under 'Response' copy the module entity type id and paste it in the txt file

Setup a deployment:
* Under evp-deployment-controller
* In the ```POST /api/evp/v1/deployment``` endpoint
* Insert the parameter:
```
{
  "instanceSpecs": {"config-echo-instance": {"version": 1, "moduleId": "<insert module id>", "entryPoint": "main", "publish": {}, "subscribe": {}}},
  "targetCondition": {"id": "<insert device id>"},
  "priority": 1,
  "publishTopics": {},
  "subscribeTopics": {}
}
```
* Under 'Response' copy the deployment entity type id and paste it in the txt file


Test device instance:
* Under evp-device-controller
* In the ```POST /api/evp/v1/devices/{deviceId}/module_instances/{instanceName}/commands``` endpoint
* Insert the parameters:
```
deviceId: <insert device id>
instanceName: config-echo-instance
payload: {"method": "echo", "params": "test"}
```
If everything worked fine you should see the message in your EVP Agent
and get an accurate response back.




