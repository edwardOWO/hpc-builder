# 移除可能衝突的套件
dnf remove -y \
  docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-engine \
  podman-docker \
  runc || true

# 安裝 repository 管理工具
dnf install -y dnf-plugins-core

# 加入 Docker 官方 Repository
dnf config-manager \
  --add-repo \
  https://download.docker.com/linux/rhel/docker-ce.repo

# 查看 Rocky 9 實際可用版本
dnf list docker-ce --showduplicates | sort -r

# 安裝 Docker
dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 啟動並設為開機啟動
systemctl enable --now docker

# 確認版本
docker version
docker compose version

# 測試
docker run hello-world
