#!/bin/bash
set -e

# ============================================================
# Spack + Lmod Global Environment Setup
#
# Requirements:
#   - Run this script as root
#   - Lmod is already installed
#
# Result:
#   /opt/spack
#   /etc/profile.d/spack.sh
#   /etc/profile.d/lmod.sh
#
# All users can use:
#   spack
#   module
#
# Spack modules:
#   /opt/spack/share/spack/lmod
# ============================================================

SPACK_ROOT="/opt/spack"
SPACK_BRANCH="releases/v1.2"
SPACK_LMOD_ROOT="${SPACK_ROOT}/share/spack/lmod/linux-rocky9-x86_64/Core/linux-rocky9-x86_64/Core"


echo "============================================================"
echo " Spack + Lmod Global Setup"
echo "============================================================"

# ------------------------------------------------------------
# 1. Check root
# ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Please run this script as root."
    exit 1
fi

# ------------------------------------------------------------
# 2. Check required commands
# ------------------------------------------------------------

for cmd in git find chmod chown mkdir; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: command not found: $cmd"
        exit 1
    fi
done

# ------------------------------------------------------------
# 3. Install Spack
# ------------------------------------------------------------

echo
echo "[1/7] Installing Spack..."

if [ -d "${SPACK_ROOT}/.git" ]; then

    echo "Spack already exists:"
    echo "    ${SPACK_ROOT}"

else

    mkdir -p "$(dirname "${SPACK_ROOT}")"

    git clone \
        --depth=2 \
        --branch="${SPACK_BRANCH}" \
        https://github.com/spack/spack.git \
        "${SPACK_ROOT}"

fi

# ------------------------------------------------------------
# 4. Set Spack permissions
# ------------------------------------------------------------

echo
echo "[2/7] Setting Spack permissions..."

chown -R root:root "${SPACK_ROOT}"
chmod -R a+rX "${SPACK_ROOT}"

# ------------------------------------------------------------
# 5. Create global Spack environment
# ------------------------------------------------------------

echo
echo "[3/7] Creating /etc/profile.d/spack.sh..."

cat > /etc/profile.d/spack.sh <<'EOF'
# ============================================================
# Spack Global Environment
# ============================================================

export SPACK_ROOT="/opt/spack"

if [ -f "${SPACK_ROOT}/share/spack/setup-env.sh" ]; then
    . "${SPACK_ROOT}/share/spack/setup-env.sh"
fi
EOF

chmod 644 /etc/profile.d/spack.sh

# Load Spack for current shell
source /etc/profile.d/spack.sh

# ------------------------------------------------------------
# 6. Configure Spack Lmod
# ------------------------------------------------------------

echo
echo "[4/7] Configuring Spack Lmod..."

mkdir -p "${SPACK_LMOD_ROOT}"

# Detect existing site configuration
SPACK_CONFIG="${SPACK_ROOT}/etc/spack"

mkdir -p "${SPACK_CONFIG}"

cat > "${SPACK_CONFIG}/modules.yaml" <<EOF
modules:
  default:
    enable:
    - lmod

    roots:
      lmod: ${SPACK_LMOD_ROOT}

    lmod:
      core_compilers:
      - gcc@11.5.0/4hw7mpqy3tm3fqr2cizadb4xsvxf2bap

      all:
        autoload: direct

      hierarchy:
      - mpi

    prefix_inspections:
      ./bin:
      - PATH
      ./man:
      - MANPATH
      ./share/man:
      - MANPATH
      ./share/aclocal:
      - ACLOCAL_PATH
      ./lib/pkgconfig:
      - PKG_CONFIG_PATH
      ./lib64/pkgconfig:
      - PKG_CONFIG_PATH
      ./share/pkgconfig:
      - PKG_CONFIG_PATH
      ./:
      - CMAKE_PREFIX_PATH
EOF

echo "Spack Lmod configuration:"
echo
cat "${SPACK_CONFIG}/modules.yaml"
echo

# ------------------------------------------------------------
# 7. Find existing Lmod
# ------------------------------------------------------------

echo "[5/7] Detecting existing Lmod..."

LMOD_INIT=""

# Common locations first
for path in \
    /opt/lmod/lmod/init/bash \
    /opt/apps/lmod/lmod/init/bash \
    /usr/share/lmod/lmod/init/bash \
    /usr/share/lmod/init/bash \
    /usr/local/lmod/lmod/init/bash
do
    if [ -f "$path" ]; then
        LMOD_INIT="$path"
        break
    fi
done

# If not found, search filesystem
if [ -z "${LMOD_INIT}" ]; then
    LMOD_INIT=$(find /opt /usr /usr/local \
        -type f \
        -path "*/lmod/init/bash" \
        2>/dev/null | head -n 1 || true)
fi

if [ -z "${LMOD_INIT}" ]; then
    echo
    echo "ERROR: Lmod was not found."
    echo
    echo "Please check with:"
    echo
    echo "    find / -type f -path '*/lmod/init/bash' 2>/dev/null"
    echo
    exit 1
fi

echo
echo "Found Lmod:"
echo "    ${LMOD_INIT}"

# ------------------------------------------------------------
# 8. Create global Lmod environment
# ------------------------------------------------------------

echo
echo "[6/7] Creating /etc/profile.d/lmod.sh..."

cat > /etc/profile.d/lmod.sh <<EOF
# ============================================================
# Lmod Global Environment
# ============================================================

if [ -f "${LMOD_INIT}" ]; then
    . "${LMOD_INIT}"
fi

# Spack generated Lmod modulefiles
if [ -d "${SPACK_LMOD_ROOT}" ]; then
    module use "${SPACK_LMOD_ROOT}"
fi
source /usr/share/lmod/lmod/init/bash


EOF

chmod 644 /etc/profile.d/lmod.sh

# Load Lmod now
source /etc/profile.d/lmod.sh

# ------------------------------------------------------------
# 9. Generate Lmod modulefiles
# ------------------------------------------------------------

echo
echo "[7/7] Generating Spack Lmod modulefiles..."

spack module lmod refresh --delete-tree -y

echo
echo "Spack Lmod modulefiles:"
echo

find "${SPACK_LMOD_ROOT}" -type f | sort || true

# ------------------------------------------------------------
# 10. Verify
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Verification"
echo "============================================================"

echo
echo "----- Spack -----"

echo "Spack version:"
spack --version

echo
echo "Spack location:"
command -v spack

echo
echo "----- Lmod -----"

echo "Lmod init:"
echo "    ${LMOD_INIT}"

echo
echo "Module version:"
module --version 2>&1 | head -n 3

echo
echo "Module location:"
type -a module 2>/dev/null || true

echo
echo "----- MODULEPATH -----"

echo "${MODULEPATH}" | tr ':' '\n'

echo
echo "----- Spack Lmod -----"

echo "Lmod root:"
echo "    ${SPACK_LMOD_ROOT}"

echo
echo "----- Module Available -----"

module avail

echo
echo "============================================================"
echo " Setup completed successfully."
echo "============================================================"

echo
echo "Global files:"
echo
echo "    /etc/profile.d/spack.sh"
echo "    /etc/profile.d/lmod.sh"
echo
echo "Spack Lmod root:"
echo
echo "    ${SPACK_LMOD_ROOT}"
echo
echo "Users can now use:"
echo
echo "    module avail"
echo "    module load <package>"
echo
