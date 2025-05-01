all: check

SHELL := /bin/bash

.PHONY: \
	all \
	check \
	check_os_version \
	check_package_versions

check_package_versions:
	ansible --version  | grep "core 2\."
	neofetch --version | grep "^Neofetch 7\."
	nvim --version     | grep "^NVIM v0.11\."
	rich --version     | grep "^1\."

check_os_version:
	cat /etc/os-release | grep "24.04"
	cat /etc/os-release | grep "Noble Numbat"
	cat /etc/os-release | grep "LTS"

check: \
		check_package_versions \
		check_os_version

setup_server:
	ansible-playbook ansible/development.yml
