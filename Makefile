all: check

SHELL := /bin/bash

.PHONY: \
	all \
	check \
	check_os_version \
	check_package_versions \
	setup

check_package_versions:
	batcat --version              | grep "^bat 0\."
	dpkg --list                   | grep libxml2-dev # required for R laguage server
	fdfind --version              | grep "^fdfind 9\."
	gemini --version              | grep "^0\."
	lua-language-server --version | grep "^3\."
	neofetch --version            | grep "^Neofetch 7\."
	node --version                | grep "^v22\."
	npm --version                 | grep "^10\."
	nvim --version                | grep "^NVIM v0.12\."
	opencode --version            | grep "^1\."
	pyright --version             | grep "^pyright 1\."
	R --version                   | grep "^R version 4\."
	rg --version                  | grep "^ripgrep 14\."
	Rscript -e "packageVersion('languageserver')" | grep "0\."
	tmux -V                       | grep "^tmux 3\."
	tree-sitter --version         | grep "^tree-sitter 0\."

check_os_version:
	cat /etc/os-release | grep "24.04"
	cat /etc/os-release | grep "Noble Numbat"
	cat /etc/os-release | grep "LTS"

check: \
		check_package_versions \
		check_os_version

setup:
	ansible-playbook ansible/development.yml
