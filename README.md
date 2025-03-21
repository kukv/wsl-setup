# wsl-setup

## 事前セットアップ

ユーザーとパスワードをセットアップしておく

user: tech

## How to use

rootで実施する

```bash
curl -sf https://raw.githubusercontent.com/kukv/wsl-setup/refs/heads/main/init.sh | bash -s
```

memo

```bash
ansible-pull -U https://github.com/kukv/wsl-setup.git -i inventory.yaml playbook.yaml
```
