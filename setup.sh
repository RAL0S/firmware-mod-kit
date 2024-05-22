#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/RAL0S/firmware-mod-kit/releases/download/v0.99-8403a17/fmk_0.99-8403a17_amd64.snap -O $RALPM_TMP_DIR/fmk_0.99-8403a17_amd64.snap
  sudo snap install $RALPM_TMP_DIR/fmk_0.99-8403a17_amd64.snap --devmode
  rm $RALPM_TMP_DIR/fmk_0.99-8403a17_amd64.snap

  echo "#!/usr/bin/env sh" > $RALPM_PKG_BIN_DIR/extract-firmware.sh
  echo 'sudo fmk.extract-firmware "$@"' >> $RALPM_PKG_BIN_DIR/extract-firmware.sh
  chmod +x $RALPM_PKG_BIN_DIR/extract-firmware.sh

  echo "#!/usr/bin/env sh" > $RALPM_PKG_BIN_DIR/build-firmware.sh
  echo 'sudo fmk.build-firmware "$@"' >> $RALPM_PKG_BIN_DIR/build-firmware.sh
  chmod +x $RALPM_PKG_BIN_DIR/build-firmware.sh

  echo "This package provides the following commands
    - extract-firmware.sh
    - build-firmware.sh"
}

uninstall() {
  sudo snap remove fmk
  rm $RALPM_PKG_BIN_DIR/extract-firmware.sh
  rm $RALPM_PKG_BIN_DIR/build-firmware.sh
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1