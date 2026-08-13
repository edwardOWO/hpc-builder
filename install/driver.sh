# 安裝 NVIDIA CUDA Repository
dnf config-manager --add-repo \
  https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo

# 安裝 NVIDIA Driver R580
dnf module install -y nvidia-driver:580

# 啟用 NVIDIA Persistence Daemon
systemctl enable --now nvidia-persistenced

# 確認 Driver
nvidia-smi
