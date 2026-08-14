# disable modules
mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.disabled
mv /etc/profile.d/modules.csh /etc/profile.d/modules.csh.disabled



git clone --depth=2 --branch=releases/v1.2 https://github.com/spack/spack.git /opt/spack


cat > /etc/profile.d/spack.sh <<'EOF'
#!/bin/bash

export SPACK_ROOT=/opt/spack

if [ -f "${SPACK_ROOT}/share/spack/setup-env.sh" ]; then
    source "${SPACK_ROOT}/share/spack/setup-env.sh"
fi
EOF

chmod 644 /etc/profile.d/spack.sh

# 直接啟用
export SPACK_ROOT=/opt/spack
source "/opt/spack/share/spack/setup-env.sh"




cat > /etc/profile.d/lmod.sh <<'EOF'
#!/bin/bash

source /usr/share/lmod/lmod/init/bash

module use /opt/modulefiles/linux-rocky9-x86_64/Core
module use /opt/nvidia/hpc_sdk/modulefiles
EOF

chmod 644 /etc/profile.d/lmod.sh

# 直接啟用
source /usr/share/lmod/lmod/init/bash
module use /opt/modulefiles/linux-rocky9-x86_64/Core
module use /opt/nvidia/hpc_sdk/modulefiles


# add permision
groupadd spack
usermod -aG spack rocky
chown -R root:spack /opt/spack
chmod -R g+rwX /opt/spack


# 設定 modulefiles module 路徑
spack config add "modules:default:enable:[lmod]"
spack config add 'modules:default:roots:lmod:/opt/modulefiles'
spack config add 'config:install_tree:root:/opt/software'
spack config add modules:default:lmod:hide_implicits:true

spack install cuda@11.8
spack install cuda@12.9.1
spack install cuda@13.0

spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@11.8
spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@12.9.1
spack install openmpi@5.0.8 +cuda fabrics=ucx ^ucx +cuda ^cuda@13.0

spack module lmod refresh -y
spack clean --downloads
dnf clean all


