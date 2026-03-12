1 - TF state and indempotency

This module aims to explain core principle of terraform operation - idempotency and state preservation.
After each apply operation, terraform writes state of enviroment to special "cache file" that should be stored in persistent place.
This cache file is then used in another terraform run to read what is already present on enviroment, what can is present in configuration and plan actions that have to be performed to even state and configuration.
Thanks to that, after applying same config two times on same enviroment terraform will not do anything - it will know what already is done and that it does not need to do anything to make env. be equal to configuration.

This simple exampple will:

- Create local terraform.tfstate file that holds cache - file will be created in ./state/ dir.
- Add two files on local disk in result directory - those only simulate real life objects like ec2

How to use:

Scenario 1 - Intended working loop:
- run terraform init from inside of path
- run terraform plan - this will show what terraform wants to do
Ex plan:

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.server1 will be created
  + resource "local_file" "server1" {
      + content              = "im server 1!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./result/server1.foo"
      + id                   = (known after apply)
    }

  # local_file.server2 will be created
  + resource "local_file" "server2" {
      + content              = "im server 2!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./result/server2.foo"
      + id                   = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

- run terraform apply - this will create files on disk, AND tfstate file that holds state
this is folder structure after this operation:
├── result
│   ├── server1.foo
│   └── server2.foo
├── state
│   └── terraform.tfstate
- run terraform plan again - at this point thanks to state file TF knows that files are already in place and there is nothing to be done

Following message will be shown:
No changes. Your infrastructure matches the configuration.

This scenario proves that terraform knows the state in which enviroment is, and applying same config multpiple times will not result in multiple resources being created.



<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Scenario 2 - what will happen if state goes missing
- remove state file that was created in previous run - rm state/terraform.tfstate 
- run terraform plan
- plan will show that it wants to readd existing files - this is not idempotent!
Due to specific of local provisioner applying those changes will not make any actual difference - but in practice, it will want to create another set of s3, ec2 server etc
This is generally an error - state file has to be protected and backed up as one of most important element of deployment

Scenario 3 - Adding new resource to existing setup

- Start with finishing scenario 1 - we will have two files in result dir AND terraform.state file in state dir
- Uncoment resource "local_file" "server3"  part of main.tf
- run terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.server3 will be created
  + resource "local_file" "server3" {
      + content              = "im server 3!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./result/server3.foo"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
Now thanks to terraform.tfstate file, terraform knows what was already done (server1 and server2 files) and what needs to be added to make enviroment (in this case our disk) equal to configuration.
State is missing server3 definition, configuration has it so it needs to add it.

In practice, tfstate has to be stored in safe and secure and most important persistent storage.