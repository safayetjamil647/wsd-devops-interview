#!/bin/bash

set -e

echo "Starting full Ansible automation..."

INVENTORY="ansible/inventory.yml"


echo "Configuring logrotate cron job..."
ansible-playbook -i $INVENTORY ansible/logrotate_cron.yml
echo "NTP setup.Custom-Template"
ansible-playbook -i $INVENTORY ansible/installer.yml

echo "Running NRPE + NTP setup..."
ansible-playbook -i $INVENTORY ansible/setup-ntp-nrpe.yml
# Step 3: Configure Nagios hosts and services
echo "Pushing Nagios host + service config..."
ansible-playbook -i $INVENTORY ansible/config-nagios-host.yml

echo "All Ansible scripts executed successfully!"
