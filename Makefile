all: check

SHELL := /bin/bash

.PHONY: \
	all \
	check \
	check_os_version \
	check_package_versions \
	setup_client \
	setup_server

check_package_versions:
	pi --version                  | grep "^0\."
	batcat --version              | grep "^bat 0\."
	dpkg --list                   | grep libuv1-dev  # required for R laguage server
	dpkg --list                   | grep libxml2-dev # required for R laguage server
	fastfetch --version           | grep "^fastfetch 2\."
	fdfind --version              | grep "^fdfind 10\."
	gh --version                  | grep "^gh version 2\."
	lua-language-server --version | grep "^3\."
	node --version                | grep "^v24\."
	npm --version                 | grep "^11\."
	nvim --version                | grep "^NVIM v0.12\."
	opencode --version            | grep "^1\."
	pyright --version             | grep "^pyright 1\."
	R --version                   | grep "^R version 4\."
	rg --version                  | grep "^ripgrep 15\."
	Rscript -e "packageVersion('languageserver')" | grep "0\."
	tmux -V                       | grep "^tmux 3\."
	tree-sitter --version         | grep "^tree-sitter 0\."

check_os_version:
	cat /etc/os-release | grep "26.04"
	cat /etc/os-release | grep "LTS"
	cat /etc/os-release | grep "Resolute Raccoon"

check: \
		check_package_versions \
		check_os_version

setup_client:
	ansible-playbook ansible/development.yml --limit localhost

setup_server:
	ansible-playbook ansible/development.yml --limit islasgeci.dev
