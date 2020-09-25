# devops-challenge_env

## Usage

### Packer

#### Step 1

##### Modify Packer config

File: ./packer/docker-node.json
Specify "profile", "region", "instance_type"

#### Step 2

##### Build AWS AMI with Packer

packer build packer/*.json


### Terraform

#### Step 1

##### Modify Terraform configs

Files: ./terraform/providers.tf, terraform/variables.tf
Specify your parameters

#### Step 2

##### Initialize terraform

cd terraform; terraform init

#### Step 3

##### See the changes and approve if you agree with them

terraform apply

#### Step 4

##### Use the IP address in the output to reach the server. You'll need it while deploying and to access the server itself

