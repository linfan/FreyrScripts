# AWS-UTILS

Bash scripts to simplify aws ec2 operation.

## How to use these scripts

These scripts need 'aws' cli, install and configure it via:

```
$ pip install awscli
$ aws configure
```

Add below line in your `.bashrc` or `.zshrc` file to auto load these commands:
```
source ~/Scripts/aws-utils/init.sh
```
> PS: Change `~/Scripts` to other folder which content script files.

## Functions provided by these scripts

### aws-ec2.sh
- ec2-create
- ec2-bulk-create
- ec2-rename
- ec2-get-id
- ec2-get-ip
- ec2-get-name
- ec2-get-status
- ec2-start
- ec2-stop
- ec2-terminate

### aws-ssh.sh
- ec2-ssh-to
- ec2-ssh-copy-from
- ec2-ssh-copy-to
- ec2-ssh-proxy
- ec2-ssh-bulk-exec

### aws-account.sh
- aws-account-list
- aws-account-switch
- aws-account-save-as
- aws-account-delete

### aws-region.sh
- aws-region-list
- aws-region-switch

### aws-profile.sh
- aws-profile-show
- aws-profile-save
- aws-profile-save-to
- aws-profile-list
- aws-profile-apply
- aws-profile-edit
- aws-profile-delete

## Dependence between scripts

There is no bidirection dependence among those scripts.
The dependence order describe as below:

- all scripts can depend on `aws-util`
- `aws-profile` depend on `aws-region` and `aws-account`
- `aws-ec2` depend on `aws-profile`
- `aws-ssh` depend on `aws-ec2`
