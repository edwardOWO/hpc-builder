curl -fsSL https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
  | tee /etc/yum.repos.d/nvidia-container-toolkit.repo

dnf clean expire-cache

dnf install -y nvidia-container-toolkit

nvidia-ctk runtime configure --runtime=docker



sudo dnf config-manager --add-repo https://developer.download.nvidia.com/hpc-sdk/rhel/nvhpc.repo

sudo dnf install -y nvhpc-24-11
sudo dnf install -y nvhpc-23-11
sudo dnf install -y nvhpc-22.11
