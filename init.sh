#! /bin/bash

# Enable swap to prevent crashing of leaking applications
fallocate -l $(awk '/MemTotal/ { printf "%.0f \n", $2*1024/2 }' /proc/meminfo) /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Tweak swap variables for maximum performance
sudo sysctl vm.swappiness=15
sudo sysctl vm.vfs_cache_pressure=50

# Ensure swap is persistent on server shutdown
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Reset the kubernetes cluster
kubeadm reset

# Ensure the kubelet is operating in the private networking cluster
echo "Environment=\"KUBELET_EXTRA_ARGS=--fail-swap-on=false --node-ip=$(curl http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

# Join the private cluster, provided by a secret environment variable
$KUBEADM_JOIN_COMMAND
