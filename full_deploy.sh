#!/bin/bash

echo "Running Terraform apply"
terraform_apply="terraform apply -auto-approve"
$terraform_apply || { echo "Terraform failed"; exit 1; }

echo "cd to playbooks directory"
cd ./playbooks || { echo "Cd to playbooks folder"; exit 1; }

echo "Running Ansible playbook to install Docker"
ansible_playbook_install_docker="ansible-playbook ./install-docker-pb.yml"
$ansible_playbook_install_docker || { echo "Install Docker playbook failed"; exit 1; }

echo "Running Ansible playbook to send environment variables"
ansible_playbook_send_env="ansible-playbook ./send-env.pb.yml"
$ansible_playbook_send_env || { echo "Send env playbook failed"; exit 1; }

echo "Running Ansible playbook to start Docker"
ansible_playbook_start_docker="ansible-playbook ./start-docker.pb.yml"
$ansible_playbook_start_docker || { echo "Start Docker playbook failed"; exit 1; }

echo "All commands executed successfully"

