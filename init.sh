#!/usr/bin/env bash

set -Eeuo pipefail

OP_USER="tech"

function password_less_privilege_escalation() {
  if [ ! -d "/etc/sudoers.d" ]; then
      mkdir -p /etc/sudoers.d
  fi

  if [ ! -f "/etc/sudoers.d/${OP_USER}" ]; then
      echo "${OP_USER} ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/${OP_USER} > /dev/null
      chmod 440 /etc/sudoers.d/${OP_USER}
  else
      if ! grep -q "${OP_USER} ALL=(ALL) NOPASSWD: ALL" /etc/sudoers.d/${OP_USER}; then
          echo "${OP_USER} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers.d/${OP_USER} > /dev/null
      fi
  fi

}

function requirement_package() {
    apt-add-repository ppa:ansible/ansible -y
    apt update && apt upgrade -y

    apt install -y \
      ansible \
      git

    apt autoremove -y
}

function ansible_setup() {
    ansible_logtotate_conf="/etc/logrotate.d/ansible-pull"
    ansible_log_dir="/home/${OP_USER}/.logs"
    ansible_pull_log_filename="ansible-pull.log"

    if [ ! -d "${ansible_log_dir}" ]; then
        echo "Creating directory: ${ansible_log_dir}"
        mkdir -p "${ansible_log_dir}"
        chmod -R 755 "${ansible_log_dir}"
        chown -R ${OP_USER}:${OP_USER} "${ansible_log_dir}"
        echo "Directory created and permissions set."
    else
        echo "Directory already exists: ${ansible_log_dir}"
    fi

    cat <<EOF > ${ansible_logtotate_conf}
${ansible_log_dir}/${ansible_pull_log_filename} {
    compress
    missingok
    rotate 365
    daily
    dateext
    copytruncate
}
EOF

    logrotate -d ${ansible_logtotate_conf}
}

password_less_privilege_escalation
requirement_package
ansible_setup
