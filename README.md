# Ansible
The harden-rhel Ansible role can be example for simple hardening of RHEL
# Packer:
Update packer-var.json prior to building the images.

Packer Build Commands from the packer directory holding the .pkr.hcl you want to build:

`packer build -var-file=../../packer-vars.json rhel.pkr.hcl`

# Validate
AWS CLI
`/usr/bin/aws --version`

ClamAV
`/usr/bin/clamscan --version`
