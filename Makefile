.PHONY: lint fmt

lint:
	yamllint --no-warnings .
	ansible-lint

fmt:
	ansible-lint --fix
