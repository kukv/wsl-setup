# wsl-setup

WSL2の環境をコマンド1つである程度構築してくれるスクリプト群です。
基本的にどこ行ってもこのコマンド1つで代替開発できるだろうというものをansibleでセットアップします。

## 事前セットアップ

ユーザーとパスワードをセットアップしておく

## How to use

rootで実施する

```bash
curl -sf https://raw.githubusercontent.com/kukv/wsl-setup/refs/heads/main/init.sh | bash -s -- --user <開発で利用するユーザー> --timer <プロビジョニングを行う頻度>
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
