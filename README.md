# wsl-setup

WSL2の環境をコマンド1つである程度構築してくれるスクリプト群です。  
基本的にどこ行ってもこのコマンド1つで大体開発できるだろうというものをansibleでセットアップします。

## Ansibleによってインストール・設定される機能

### システム設定

**基本的なシステムパッケージ**  

インストールされるパッケージは以下に定義されている  
[ansible/roles/system_configuration/defaults/main.yaml](ansible/roles/system_configuration/defaults/main.yaml)

**ターミナル**

本セットアップではデフォルトのShellを[ZSH](https://sourceforge.net/p/zsh/code/ci/master/tree/)に切り替えている。  
またZSHの管理フレームワークとしてOh-my-zshを採用。

**その他システム設定**

- SSH-agent設定  
  本セットアップでは1Passwordによるパスワード管理を前提としているため、SSH等のコマンドは[AliasでWindowsのSSH CLIを利用する](https://github.com/kukv/wsl-setup/blob/main/ansible/roles/system_configuration/templates/.zshrc.generated.j2#L92-L94)よう設定している。
- DNS設定
  DNSサーバーは以下を利用している  
  [ansible/roles/system_configuration/tasks/dns_resolver_configuration.yaml](ansible/roles/system_configuration/tasks/dns_resolver_configuration.yaml)
- Time locale設定
  NTPサーバーは以下を利用している  
  [ansible/roles/system_configuration/tasks/time_locale_configuration.yaml](ansible/roles/system_configuration/tasks/time_locale_configuration.yaml)
- WSL設定（/etc/wsl.conf only）

### 開発環境

**パッケージマネージャー**

本セットアップではユーザー向けパッケージの管理として以下のマネージャーを利用する。

- Homebrew（パッケージマネージャー）
- Mise（バージョン管理ツール）

**対応する開発環境**

開発環境を構築するうえではmiseを利用する。  
インストールされるパッケージは以下で定義している。  
[ansible/roles/dev_setup/templates/config.toml.j2](ansible/roles/dev_setup/templates/config.toml.j2)

- 各種プログラミング言語環境：
  - Clang/C++
  - JVM
    - Java
    - Kotlin
  - Node.js
  - Python
  - Golang
  - Ruby
- 開発ツール：
  - バージョン管理システム（Git等）
  - AWS CLI
  - Kubernetes関連ツール
  - Vim
  - terraform
  - etc...

### 自動プロビジョニング

本セットアップは自身でプロビジョニングが行えるよう、pull型のansibleを採用している。  
また、常にWSL環境が最新になるよう、Systemd-timerを利用して定期的にansibleを実行するよう設定している。  

**定期的なプロビジョニングの頻度について**
デフォルトでは毎週実施する設定なっている。  
この頻度は、ansible実行用の変数で変更可能。  
[ansible/roles/provisioning_schedule/templates/wsl-setup.timer.j2](ansible/roles/provisioning_schedule/templates/wsl-setup.timer.j2)

## 事前セットアップ

ユーザーとパスワードをセットアップしておく。

ansible実行用の変数ファイルを追加

```bash
mkdir -p /etc/ansible

cat <<EOF >> /etc/ansible/extra_vars.yaml
---
# Ansible実行過程で、GithubAPIのrate limitを回避するために必要
github_token: "your_github_token_here"

# プロビジョニングを定期的に実施する期間を指定
# systemd-timerを利用している為、以下の書式で指定可能です。
# - https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html
provisioning_schedule: "weekly"

# git configで設定する値を指定します。
# Gitの基本設定をグローバルに適用します。
git_configs:
  - name: "user.name"
    value: "username"
  - name: "user.email"
    value: "test@example.com"
  - name: "color.ui"
    value: "auto"

# 追加のシェルエイリアス設定
aliases:
  - command: "relogin"
    target: "exec $SHELL -l"
  - command: "reload"
    target: "source ~/.zshrc"
EOF
```

## How to use

#### rootで実施する

```bash
curl -sf https://raw.githubusercontent.com/kukv/wsl-setup/refs/heads/main/init.sh | bash -s -- --user <開発で利用するユーザー>
```

`init.sh`のオプション：
- `-u, --user`: システム開発を行うユーザーを指定（必須）
- `-b, --branch`: プロビジョニングを行うブランチを指定
- `-h, --help`: ヘルプを表示


#### 上記コマンドを実行後、WSL2を再起動してください。

```powershell
wsl --shutdown
```

### プロビジョニングログの場所

プロビジョニングログは以下に格納されている

```bash
/var/log/ansible/ansible-pull.log
```

## 開発環境の構築方法

本リポジトリの開発環境はDocker上で構築している。  
理由としてはLinterライブラリの一部がWindows上で動作しないため。  

#### プロジェクトのセットアップ

```bash
make up
make     # ansibleのコレクション周りをセットアップするために、実行する必要がある
```

## テスト環境の構築

このプロジェクトはDockerを使用してAnsibleプレイブックをテストするための環境を提供しています。

#### Dockerテスト環境

- `compose.yaml`: Ansibleテスト用のDockerコンテナを定義
- `docker/mock/Dockerfile`: Ubuntu 24.04ベースのテスト環境を構築
- `docker/mock/etc/extra_vars.yaml`: テスト用のAnsible変数を設定

#### Makefileコマンド

```bash
# Dockerコンテナの起動
make up

# Dockerコンテナの初期化
make reset

# テストコンテナにログイン
make login

# Ansibleプレイブックの実行
make play

# 特定のタグを指定してAnsibleプレイブックを実行
make play/<タグ名>
```

## コーディング規約に関して

本リポジトリは以下のlintでコード品質を担保している

- yamllint
- ansible-lint
- shellcheck

これらはCIで検査している為、以下のコマンドを実行しエラーがないことを確認した後Pushすることを推奨する

```bash
# コードの品質チェック
make check
```
