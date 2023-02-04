# Terraform AWS Infrastructure

This Terraform project sets up a basic infrastructure in AWS, including:
- Virtual Private Cloud (VPC)
- Private and public subnets
- Internet gateway
- NAT gateway in the public subnet
- Route tables
- EC2 instances in both the private and public subnets

### Requirements
- Terraform 0.13 or later
- An AWS account with the necessary permissions to create resources

### Usage
1 Clone the Repository
```
git clone https://github.com/Celnet-hub/terraform-aws-infrastructure.git
```

2 Initialize Terraform
```
terraform init
```
3 Set Up [AWS CLI](https://aws.amazon.com/cli/) 
    - The AWS credentials used will be referanced in the terraform configuration

4 Plan and apply the Terraform code
```
terraform plan
terraform apply
```
### Cleanup
To destroy the resources created by this project, run the following command:
```
terraform destroy
```
