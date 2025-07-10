# wsl-setup

WSL2の環境をコマンド1つである程度構築してくれるスクリプト群です。
基本的にどこ行ってもこのコマンド1つで大体開発できるだろうというものをansibleでセットアップします。

## このAnsibleによってインストール・設定される機能

### システム設定

- 基本的なシステムパッケージ
- Oh-my-bash
- SSH-agent設定
- DNS設定
- NTPサーバー設定
- タイムゾーン設定
- WSL設定（/etc/wsl.conf only）

### 開発環境

- パッケージマネージャー
  - Homebrew（パッケージマネージャー）
  - Mise（バージョンマネージャー）
- 各種プログラミング言語環境：
  - Clang/C++
  - Java/JVM言語
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

- 定期的なプロビジョニングの設定
- ansible-pullによる最新設定の自動適用
- プロビジョニングログのローテーション設定

## 事前セットアップ

ユーザーとパスワードをセットアップしておく。

ansible実行用の変数ファイルを追加

```bash
mkdir -p /etc/ansible

cat <<EOF >> /etc/ansible/extra_vars.yaml
---
# プロビジョニングを定期的に実施する期間を指定
# systemd-timerを利用している為、以下の書式で指定可能です。
# - https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html
provisioning_schedule: "weekly"

# git configで設定する値を指定します。
git_configs:
  - name: "user.name"
    value: "<git user>"
  - name: "user.email"
    value: "<git email>"
  - name: "color.ui"
    value: "auto"

aliases:
  - command: "relogin"
    target: "exec $SHELL -l"
  - command: "reload"
    target: "source ~/.bashrc"
EOF
```

## How to use

#### rootで実施する

```bash
curl -sf https://raw.githubusercontent.com/kukv/wsl-setup/refs/heads/main/init.sh | bash -s -- --user <開発で利用するユーザー>
```

`init.sh`のオプション：
- `-u, --user`: システム開発を行うユーザーを指定（必須）
- `-h, --help`: ヘルプを表示


#### 上記コマンドを実行後、WSL2を再起動してください。

```powershell
wsl --shutdown
```

以降は`systemd-timer`にて定期的に`ansible-pull`によりプロビジョニングが行われます。

### プロビジョニングログの場所

プロビジョニングログは以下に格納されている

```bash
/var/log/ansible/ansible-pull.log
```

## 開発環境の構築方法

#### required libraries

- python >=3.13
- poetry >=2.1.2
- shellcheck >=0.10.0

#### プロジェクトの初期化(python環境のセットアップ)

```bash
make install
```

## テスト環境の構築

このプロジェクトはDockerを使用してAnsibleプレイブックをテストするための環境を提供しています。

#### Dockerテスト環境

- `compose.yaml`: Ansibleテスト用のDockerコンテナを定義
- `docker/Dockerfile`: Ubuntu 24.04ベースのテスト環境を構築
- `docker/extra_vars.yaml`: テスト用のAnsible変数を設定

#### Makefileコマンド

```bash
# Dockerコンテナの起動
make up

# Dockerコンテナの停止
make down

# Dockerコンテナの再起動
make restart

# テストコンテナにログイン
make login

# Ansibleプレイブックの実行
make ansible/play

# 特定のタグを指定してAnsibleプレイブックを実行
make ansible/play/<タグ名>
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
