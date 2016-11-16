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
for f in `ls ~/Scripts/aws-utils/*.sh`; do source $f; done
```
> PS: Change `~/Scripts` to other folder which content script files.

## Functions provided by these scripts

### aws-ec2.sh
- aws-ins-bulk-create
- aws-ins-create
- aws-ins-get-id
- aws-ins-get-ip
- aws-ins-get-name
- aws-ins-get-status
- aws-ins-rename
- aws-ins-start
- aws-ins-stop
- aws-ins-terminate

### aws-ssh.sh
- aws-ssh-bulk-exec
- aws-ssh-copy-from
- aws-ssh-copy-to
- aws-ssh-proxy
- aws-ssh-to

### aws-account.sh
- aws-account-delete
- aws-account-list
- aws-account-save
- aws-account-switch

### aws-region.sh
- aws-region-switch
- aws-regions-list

### aws-profile.sh
- aws-profile-apply
- aws-profile-create
- aws-profile-delete
- aws-profile-edit
- aws-profile-list

