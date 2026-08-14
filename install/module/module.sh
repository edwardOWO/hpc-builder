# 1. 安装 CUDA 11.8 版本的 OpenMPI 环境
spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@11.8

# 2. 安装 CUDA 12.9.2 版本的 OpenMPI 环境
spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@12.9.2

# 3. 安装 CUDA 13.0 版本的 OpenMPI 环境
spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@13.0


spack module lmod refresh -y
spack clean --all
