#!/usr/bin/env bash

set -Eeuo pipefail

TEMP=$(getopt -o u:b:h -l user:,branch:,help -- "$@")
eval set -- "$TEMP"

op_user=""
op_branch="main"

function usage() {
    cat <<_EOF_
Usage: $(basename "$0") [OPTION]

Description: "$(pwd)"  WSL2セットアップ用のシェルスクリプトです。

Options:
    -u --user    | required     : システム開発を行うユーザーを指定します。
                                  ユーザーは事前に作成済みである必要があります。
    -b --branch  | optional     : Ansible実行時のブランチを指定します。指定がない場合は"main"を使用します。
    -h --help    | optional     : ヘルプを表示します。
_EOF_
}

function parameter_parsing() {
  while true; do
    case "$1" in
      -u|--user)
        op_user=$2
        shift 2
        ;;
      -b|--branch)
        op_branch=$2
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "Unknown argument: $1"
        usage
        exit 9
        ;;
    esac
  done

  if [ -z "${op_user}" ]; then
    echo "User is not specified."
    exit 9
  fi
}

function password_less_privilege_escalation() {
  user=$1
  sudoers_path="/etc/sudoers.d"

  if [ ! -d "${sudoers_path}" ]; then
      mkdir -p ${sudoers_path}
  fi

  if [ ! -f "${sudoers_path}/${user}" ]; then
      echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee "${sudoers_path}/${user}" > /dev/null
      chmod 440 "${sudoers_path}/${user}"
  else
      if ! grep -q "${user} ALL=(ALL) NOPASSWD: ALL" "${sudoers_path}/${user}"; then
          echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee -a "${sudoers_path}/${user}" > /dev/null
      fi
  fi

}

function requirement_package() {
  apt-add-repository ppa:ansible/ansible -y

  apt update
  apt upgrade -y

  apt install -y \
    ansible \
    git

  apt autoremove -y
}

parameter_parsing "$@"
password_less_privilege_escalation "${op_user}"
requirement_package

sudo -u "${op_user}" \
  bash -c "/usr/bin/ansible-pull -U https://github.com/kukv/wsl-setup.git -C ${op_branch} -i ansible/inventories/hosts.yaml ansible/playbook.yaml --extra-vars '@/etc/ansible/extra_vars.yaml' --extra-vars 'ansible_user=${op_user}'"

exit 0
