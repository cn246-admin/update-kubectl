#!/bin/sh

# Description: Download, verify and install kubectl binary on Linux and Mac
# Author: Chuck Nemeth
# https://kubernetes.io/docs/tasks/tools/

# Colored output
code_grn() { tput setaf 2; printf '%s\n' "${1}"; tput sgr0; }
code_red() { tput setaf 1; printf '%s\n' "${1}"; tput sgr0; }
code_yel() { tput setaf 3; printf '%s\n' "${1}"; tput sgr0; }

# Define funciton to delete temporary install files
clean_up() {
  printf '%s\n' "[INFO] Cleaning up install files"
  cd && rm -rf "${tmp_dir}"
}

# OS Check
os_info=$(uname -sm)
case "${os_info}" in
  Darwin\ arm64)
    os="darwin"
    arch="arm64"
    ;;
  Darwin\ x86_64)
    os="darwin"
    arch="amd64"
    ;;
  Linux\ armv[5-9]* | Linux\ aarch64*)
    os="linux"
    arch="arm64"
    ;;
  Linux\ *64)
    os="linux"
    arch="amd64"
    ;;
  *)
    code_red "[ERROR] Unsupported OS. Exiting"; exit 1 ;;
esac

# Variables
bin_dir="$HOME/.local/bin"

if command -v kubectl >/dev/null 2>&1; then
  kube_installed_version="$(kubectl version --client | awk '/Client Version:/ { print $3 }')"
else
  kube_installed_version="Not Installed"
fi

kube_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
kube_url="https://dl.k8s.io/release/${kube_version}/bin/${os}/${arch}/"
kube_binary="kubectl"
kube_sum_file="${kube_binary}.sha256"
kube_convert_binary="kubectl-convert"
kube_convert_sum_file="${kube_convert_binary}.sha256"

# PATH Check
case :$PATH: in
  *:"${bin_dir}":*)  ;;  # do nothing
  *)
    code_red "[ERROR] ${bin_dir} was not found in \$PATH!"
    code_red "Add ${bin_dir} to PATH or select another directory to install to"
    exit 1 ;;
esac

if [ "${kube_version}" = "${kube_installed_version}" ]; then
  printf '%s\n' "Installed Verision: ${kube_installed_version}"
  printf '%s\n' "Latest Version: ${kube_version}"
  code_yel "[INFO] Already using latest version. Exiting."
  exit
else
  printf '%s\n' "Installed Verision: ${kube_installed_version}"
  printf '%s\n' "Latest Version: ${kube_version}"
  tmp_dir="$(mktemp -d /tmp/kube.XXXXXXXX)"
  trap clean_up EXIT
  cd "${tmp_dir}" || exit
fi

# Download
printf '%s\n' "[INFO] Downloading the kubectl binary and verification files"
curl -sL -o "${tmp_dir}/${kube_binary}" "${kube_url}/${kube_binary}"
curl -sL -o "${tmp_dir}/${kube_sum_file}" "${kube_url}/${kube_sum_file}"

printf '%s\n' "[INFO] Downloading the kubectl convert plugin and verification files"
curl -sL -o "${tmp_dir}/${kube_convert_binary}" "${kube_url}/${kube_convert_binary}"
curl -sL -o "${tmp_dir}/${kube_convert_sum_file}" "${kube_url}/${kube_convert_sum_file}"

# Verify shasum
printf '%s\n' "[INFO] Verifying ${kube_binary}"
if ! awk -v var="${kube_binary}" '{print $1, "", var}' "${kube_sum_file}" | shasum -qc - ; then
  code_red "[ERROR] Problem with ${kube_binary} checksum!"
  exit 1
fi

printf '%s\n' "[INFO] Verifying ${kube_convert_binary}"
if ! awk -v var="${kube_convert_binary}" '{print $1, "", var}' "${kube_convert_sum_file}" | shasum -qc - ; then
  code_red "[ERROR] Problem with ${kube_convert_binary} checksum!"
  exit 1
fi

# Create directories
[ ! -d "${bin_dir}" ] && install -m 0700 -d "${bin_dir}"

# Install kubectl binary
if [ -f "${tmp_dir}/${kube_binary}" ]; then
  printf '%s\n' "[INFO] Installing the ${kube_binary} binary"
  mv "${tmp_dir}/${kube_binary}" "${bin_dir}/${kube_binary}"
  chmod 0700 "${bin_dir}/${kube_binary}"

  printf '%s\n' "[INFO] Installing the ${kube_convert_binary} binary"
  mv "${tmp_dir}/${kube_convert_binary}" "${bin_dir}/${kube_convert_binary}"
  chmod 0700 "${bin_dir}/${kube_convert_binary}"
  hash -r
fi

# VERSION CHECK
code_grn "[INFO] Done!"
code_grn "Installed Version: $(kubectl version --client | awk '/Client Version:/ { print $3 }')"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
