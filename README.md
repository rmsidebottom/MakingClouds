# MakingClouds
Various cloud deployment methods and techniques 

1. [Ansible](#ansible)

## Ansible

1. [Overview](#overview)
2. [Setup](#setup)
3. [Resources](#resources)
4. [Deploying](#deploying)
5. [Future Improvements](#future-improvements)

### Overview 
This section details how to deploy certain resources through ansible. Contained in this playbook is the code to create and deploy the following:

- A custom AWS Security Group
- SSH keys
- An EC2 instance
- A simple apache webserver
- A simple php website

### Setup
Prior to running a playbook, a couple files need to be created. Depending on your local setup, some of this may change.

#### Variables
On my local environment I was exporting the AWS key information to a specific credentials file named `creds.yml`. Should you wish to do the same, the format is:
```
AWS_ACCESS_KEY_ID: "key_id"
AWS_SECRET_ACCESS_KEY: "access_key"
```

In addition there is a separate variables file I created to help change things like region as needed. Location: `MakingClouds/AnsibleDeployment/variables.yml`
```
vpc: *vpc* 
ip: *your IP*
subnet: *subnet*
region: us-east-1
hostpath: "../hosts"
hoststring: "ansible_ssh_user=ubuntu ansible_ssh_private_key_file=../aws-private.pem"
host_ip: *ip of machine ansible running from*
```

Lastly, a host file is needed in order for SSH to work.
Location: `MakingClouds/hosts`
```
[local]
localhost

[webserver]

```

#### Python Libraries

The python libraries installed to run this are:
- ansible
- boto3
- boto
- botocore

To install `pip install ansible boto3 boto botocore`.

### Resources

#### AWS Security Group

This part of the playbook creates a security group. 

Inbound Rules:
| Protocol | Port | IP | Description |
| --- | --- | --- | --- |
| TCP | 80 | Dev IP | Allow web from IP address of the developer's machine |
| TCP | 22 | Dev IP | Allow SSH from IP address of the developer's machine |
| TCP | 22 | Deployment machine IP | Allow SSH from deployment machine IP |

Outbound Rules:
| Protocol | Port | IP | Description |
| --- | --- | --- | --- |
| TCP | 80 | Any | Allow HTTP to anywhere |
| TCP | 8080, 443 | Any | Allow HTTPS to anywhere |

The security group has a tag `EnvName: Test Environment`.

#### AWS EC2 Instance

The EC2 instance is created along with SSH keys that allow you to SSH into the instance. I used this originally to verify that the server installs went successfully. 

The EC2 instance is put on the same subnet and VPC as the security group which becomes attached to it. The current ami is set up to deploy Ubuntu 20.04 with a size set to t2.micro. 

The user data section of the EC2 instance collects a local script file and runs that on the EC2 instance when it's created. This script installs and configures a webserver to run and display the server's IP in the webbrowser. To do this, apache2 and php are installed.

```
#!/bin/bash

sudo apt-get install apache2 php -y

echo "<?php echo \$_SERVER['SERVER_ADDR'] ?>" > /var/www/html/index.php

rm /var/www/html/index.html

sudo service apache2 restart
```

The instance is also configured with a name of `customec2` and a tag `EnvName: Test Environment`.

### Deploying

To deploy this stack, run the command (from MakingClouds) `ansible-plabook -i hosts AnsibleDeployment/playbook-ssh.yml`. It will return the IP and DNS address. Running a cURL on that address will dispaly the IP address of the server once the server has been running for a couple seconds (it takes a minute for apache to get set up).

### Future Improvements
Future improvements and goals for the ansible portion are to increase security of the website, add SSL/TLS, beautify it mildly, and deploy the webserver itself in a better way through ansible. The goal is the make it a state that ansible can track instead of a start up script for the EC2 instance.

For security of ansible, the goal would be to secure secrets using ansible vault. This would be useful for securing the AWS credentials.

For webserver security, the move would be to ideally move away from PHP or at least harden the image itself.

Lastly, fix the problems encountered when running in a Python virtual environment so it is portable.