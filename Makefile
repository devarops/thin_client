all: check

SHELL := /bin/bash

.PHONY: \
	all \
	check \
	check_desktop \
	check_os_version \
	check_package_versions \
	setup_client

check_package_versions:
	batcat --version              | grep "^bat 0\."
	dpkg --list                   | grep libuv1-dev  # required for R laguage server
	dpkg --list                   | grep libxml2-dev # required for R laguage server
	fastfetch --version           | grep "^fastfetch 2\."
	fdfind --version              | grep "^fdfind 10\."
	gh --version                  | grep "^gh version 2\."
	lua-language-server --version | grep "^3\."
	node --version                | grep "^v22\."
	npm --version                 | grep "^9\."
	nvim --version                | grep "^NVIM v0\."  # the snap refreshes itself, so only pin the major version
	opencode --version            | grep "^opencode v2\."
	pi --version                  | grep "^1\."
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

check_desktop:
	ghostty --version             | grep "^Ghostty 1\."  # the snap refreshes itself, so only pin the major version
	dpkg --list                   | grep ibus-typing-booster
	fc-list                       | grep "Hack Nerd Font"
	snap list slack               | grep "^slack"

check: \
		check_package_versions \
		check_os_version \
		check_desktop

setup_client:
	ansible-playbook ansible/development.yml --limit localhost
