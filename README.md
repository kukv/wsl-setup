# wsl-setup

WSL2の環境をコマンド1つである程度構築してくれるスクリプト群です。
基本的にどこ行ってもこのコマンド1つで代替開発できるだろうというものをansibleでセットアップします。

## 事前セットアップ

ユーザーとパスワードをセットアップしておく。

ansible実行用の変数ファイルを追加

```bash
mkdir -p /etc/ansible

cat <<EOF >> /etc/ansible/extra_vars.yaml
---
# プロビジョニングを定期的に実施する期間を指定
# systemd-timerを利用している為、以下の書式で指定可能です。
# - https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html****
provisioning_schedule: "weekly"

# git configで設定する値を指定します。
git_configs:
  - name: "user.name"
    value: "kukv"
  - name: "user.email"
    value: "example@test.com"
  - name: "color.ui"
    value: "auto"
EOF
```

## How to use

rootで実施する

```bash
curl -sf https://raw.githubusercontent.com/kukv/wsl-setup/refs/heads/main/init.sh | bash -s -- --user <開発で利用するユーザー>
```

上記コマンドを実行後、WSL2を再起動してください。

```powershell
wsl --shutdown
```

以降は`systemd-timer`にて定期的に`ansible-pull`によりプロビジョニングが行われます。

## 開発環境の構築方法

required libraries

- python 3.13.2

venv環境を構築
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

何かインストールしたら依存関係をエクスポートする
```bash
pip freeze > requirements.txt
```
