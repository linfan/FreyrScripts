AWS-UTILS
---

Bash scripts to simplify aws ec2 operation

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

