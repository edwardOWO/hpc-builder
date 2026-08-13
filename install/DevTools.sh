dnf install -y \
  gcc-toolset-13 \
  htop \
  ltrace \
  strace \
  perf \
  valgrind \
  patch

cat > /etc/profile.d/gcc-toolset-13.sh <<'EOF'
source /opt/rh/gcc-toolset-13/enable
EOF
