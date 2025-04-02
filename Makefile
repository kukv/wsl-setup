ANSIBLE_USER=tech

up:
	docker compose up -d

down:
	docker compose down --rmi all --remove-orphans

restart: down up

ansible/play:
	docker compose exec ansible-test sudo -u "$(ANSIBLE_USER)" bash -c "cd /ansible && ansible-playbook playbook.yaml"

ansible/play/%:
	docker compose exec ansible-test sudo -u "$(ANSIBLE_USER)" bash -c "cd /ansible && ansible-playbook playbook.yaml --tags $(@F)"









#lint:
#	yamllint --no-warnings .
#	ansible-lint
#	shellcheck *.sh
#
#fmt:
#	ansible-lint --fix
