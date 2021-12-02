
# Get Started

You need the terraform binary locally
on your computer if you want run terraform
manually and not use a CI pipeline to manage
the infrastructure you are about to create.

Terraform is readily avaiable as a pre-compiled
executable or as a package for the most 
popular operating systems. For downloads
head over to [https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started](link).

Depending on the authentication method you
plan to use you should also install the
command line client of your cloud. For
Azure you should download the Azure client
to be able to authenticate via the `az login`
command. More information can be found at [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](link).


Once Terraform is installed switch the
the project terraform folder and start
creating projects in the cloud.

For example if you want try the Fractal
application change into the projects
terrafrom folder and initalize Terraform.
To avoid problems caused by missing
permissions to register
resources not used in the examples
set the environment variable ARM_SKIP_PROVIDER_REGISTRATION
to true.

```
export ARM_SKIP_PROVIDER_REGISTRATION=true
cd terraform/azure/app-service/
terraform init
```

Afterwards you create a Terraform plan and
execute it:

```
terraform plan 
terraform apply
```
