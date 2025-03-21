.PHONY: lint fmt

lint:
	yamllint --no-warnings .
	ansible-lint
	shellcheck *.sh

fmt:
	ansible-lint --fix
