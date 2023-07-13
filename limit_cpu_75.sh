#!/bin/bash

# Define the service name
service_name="moneroocean_miner"

CPU_THREADS=$(nproc)

# Define the CPU limit percentage
cpu_limit=75*$CPU_THREADS

# Check if cpulimit is installed
if ! command -v cpulimit &> /dev/null; then
    echo "cpulimit is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install cpulimit -y
fi

# Get the PID of the service
service_pid=$(systemctl show -p MainPID "$service_name" | awk -F= '{print $2}')

# Set the CPU limit for the service
cpulimit -l "$cpu_limit" -p "$service_pid"

# Create a systemd service unit file to limit the CPU usage after reboot
cat <<EOF | sudo tee /etc/systemd/system/cpu_limit_after_reboot.service
[Unit]
Description=CPU Limit After Reboot
After=network.target

[Service]
ExecStart=/usr/bin/cpulimit -l $cpu_limit -p $service_pid

[Install]
WantedBy=default.target
EOF

# Enable the service
sudo systemctl enable cpu_limit_after_reboot.service

echo "CPU usage for service '$service_name' has been limited to $cpu_limit%."
echo "The CPU limit will be applied after every reboot as well."

