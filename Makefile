ANSIBLE_USER=tech

up:
	docker compose up -d

down:
	docker compose down -v

rmi:
	docker compose down --rmi all --volumes --remove-orphans

restart: down up

login:
	docker compose exec ansible-test login

ansible/play:
	docker compose exec ansible-test \
		sudo -u "$(ANSIBLE_USER)" \
		bash -c "ansible-playbook -i inventories/hosts.yaml playbook.yaml --extra-vars '@/etc/ansible/extra_vars.yaml' --extra-vars 'ansible_user=$(ANSIBLE_USER)'"

ansible/play/%:
	docker compose exec ansible-test \
		sudo -u "$(ANSIBLE_USER)" \
		bash -c "ansible-playbook -i inventories/hosts.yaml playbook.yaml --extra-vars '@/etc/ansible/extra_vars.yaml' --extra-vars 'ansible_user=$(ANSIBLE_USER)' --tags $(@F)"

install:
	poetry install

destroy:
	poetry env remove .venv

yamllint:
	poetry run yamllint ansible

shellcheck:
	shellcheck init.sh

ansible-lint:
	poetry run ansible-lint --config-file "ansible/.ansible-lint"

ansible-fmt:
	poetry run ansible-lint --config-file "ansible/.ansible-lint" --fix

check: yamllint shellcheck ansible-lint
