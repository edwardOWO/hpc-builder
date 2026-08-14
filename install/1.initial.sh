dnf update -y
dnf install -y epel-release


chmod 777 /tmp

dnf groupinstall -y "Development Tools"
dnf install -y \
    patch \
    git \
    tar \
    gzip \
    bzip2 \
    xz \
    unzip \
    which \
    findutils \
    diffutils \
    make \
    perl \
    python3
