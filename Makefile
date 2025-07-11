all: check

SHELL := /bin/bash

.PHONY: \
	all \
	check \
	check_os_version \
	check_package_versions

check_package_versions:
	batcat --version   | grep "^bat 0\."
	neofetch --version | grep "^Neofetch 7\."
	node --version     | grep "^v18\."
	npm --version      | grep "^9\."
	nvim --version     | grep "^NVIM v0.11\."
	pyright --version  | grep "^pyright 1\."
	rg --version       | grep "^ripgrep 14\."
	tmux -V            | grep "^tmux 3\."

check_os_version:
	cat /etc/os-release | grep "24.04"
	cat /etc/os-release | grep "Noble Numbat"
	cat /etc/os-release | grep "LTS"

check: \
		check_package_versions \
		check_os_version

setup_server:
	ansible-playbook ansible/development.yml
