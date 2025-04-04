ANSIBLE_USER=tech

up:
	docker compose up -d

down:
	docker compose down

rmi:
	docker compose down --rmi all --volumes --remove-orphans

restart: down up

login:
	docker compose exec ansible-test login

ansible/play:
	docker compose exec ansible-test \
		sudo -u "$(ANSIBLE_USER)" \
		bash -c "ansible-playbook playbook.yaml --extra-vars '@/etc/ansible/extra_vars.yaml' --extra-vars 'ansible_user=$(ANSIBLE_USER)'"

ansible/play/%:
	docker compose exec ansible-test \
		sudo -u "$(ANSIBLE_USER)" \
		bash -c "ansible-playbook playbook.yaml --extra-vars '@/etc/ansible/extra_vars.yaml' --extra-vars 'ansible_user=$(ANSIBLE_USER)' --tags $(@F)"

init:
	python -m venv .venv
	source .venv/bin/activate

activate:
	source .venv/bin/activate

deactivate:
	deactivate

install:
	pip install -r requirements.txt

lint:
	yamllint --no-warnings .
	ansible-lint --config-file "ansible/.ansible-lint"
	shellcheck *.sh

fmt:
	ansible-lint --fix --config-file "ansible/.ansible-lint"
