Multi-account terraform
=======================

This is an example of how to provision resources in multiple aws accounts.

## Usage
1. Clone this repo
2. create a file with your aws credentials in, should be named `<something>.tfvars`
```
main_access_key = "XXXXXXXXXXXXXXXXXXXX"
main_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

linked_access_key = "XXXXXXXXXXXXXXXXXXXX"
linked_secret_key= "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

region = "eu-central-1"
```
3. `terraform apply -var-file <path-to-aws-credentials-file>`
