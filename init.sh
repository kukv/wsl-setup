#!/usr/bin/env bash

set -Eeuo pipefail

OP_USER="tech"

function passwordless_privilege_escalation() {
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

function configure_git() {
    git config --global user.name "kukv"
    git config --global user.email "koki-nonaka@outlook.jp"

  if [ ! -d "" ]; then
        mkdir -p /etc/sudoers.d
  fi
}

passwordless_privilege_escalation
requirement_package
configure_git
