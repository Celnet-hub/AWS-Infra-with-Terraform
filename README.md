# Terraform AWS Infrastructure

This Terraform project sets up a basic infrastructure in AWS, including:
- Virtual Private Cloud (VPC)
- Private and public subnets
- Internet gateway
- NAT gateway in the public subnet
- Route tables for the public and private subnet
- Route table Associations
- EC2 instances in both the private and public subnets
- Security Group for the EC2 instances.

### Diagram 
![Infra Diagram](Infrastructure%20Diagram.png)


### Requirements
- Terraform 0.13 or later
- An AWS account with the necessary permissions to create resources

### Usage
1 Clone the Repository
```
git clone https://github.com/Celnet-hub/terraform-aws-infrastructure.git

```

2 Initialize Terraform: Note: I used the AWS provider in Terraform. [Read More...](https://registry.terraform.io/providers/hashicorp/aws/latest)
```
terraform init
```
3 Set Up [AWS CLI](https://aws.amazon.com/cli/) 
###### Note: 
*The AWS credentials used will be referanced in the terraform configuration file*

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
