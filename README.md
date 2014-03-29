Ansible Helper Script
=====================

Simple bash script to help with Ansible directory structure generation.
This script will generate the directory structure according to [Ansible Best Practices Directory Layout](http://docs.ansible.com/playbooks_best_practices.html)

Usage
=====

ansible-helper.sh -p "provision here" -r{"apache","mysql","gearman"}

The command above will create the ansible structure in the "./provision here" directory, with roles apache, mysql and gearman

ansible-helper.sh -r{"apache","mysql","gearman"} -o

The command above will create the the roles apache, mysql and gearman in current directory

If you do not specify the ansible project directory, the script will execute in current directory.

If you do not specify the roles, the script will generate a common role.

Use ansible-helper.sh -i for options
