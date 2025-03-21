#!/usr/bin/env bash

set -Eeuo pipefail

TEMP=$(getopt -o u:t:h -l user:,timer:,help -- "$@")

op_user=""
timer="hourly"

function usage() {
    cat <<_EOF_
Usage: $(basename $0) [OPTION]

Description: "$(pwd)"  WSL2セットアップ用のシェルスクリプトです。

Options:
    -u --user  | required     : システム開発を行うユーザーを指定します。
                                ユーザーは事前に作成済みである必要があります。
    -t --timer | optionnal    : プロビジョニングを行う頻度を指定します。
                                デフォルトでは1時間毎にプロビジョニングを行います。
                                プロビジョニングはsystemd-timerを利用している為、以下の書式で指定可能です。
                                - https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html
    -h --help  | optional     : ヘルプを表示します。
_EOF_
}

function parameter_parsing() {
  while true; do
    case "$1" in
      -u|--user)
        op_user=$2
        echo "user: $op_user"
        shift 2
        ;;
      -t|--timer)
        timer=$2
        echo "timer: $timer"
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

  if [ -z "${timer}" ]; then
    echo "Timer is not specified."
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
      echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee ${sudoers_path}/${user} > /dev/null
      chmod 440 ${sudoers_path}/${user}
  else
      if ! grep -q "${user} ALL=(ALL) NOPASSWD: ALL" ${sudoers_path}/${user}; then
          echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee -a ${sudoers_path}/${user} > /dev/null
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

home_dir="/home/${op_user}"
sudo -u ${op_user} \
  bash -c "cd ${home_dir} && /usr/bin/ansible-pull -U https://github.com/kukv/wsl-setup.git -i inventory.yaml playbook.yaml -e '{\"provisioning_schedule\":\"${timer}\"\}'"

exit 0
