# Interface

The public interface is the Makefile. These seven targets are its outermost
surface, and every one of them runs from the repository root. Each target
exits with the status of its commands.

### make all

Default target, with no arguments.

Parameters: none.

Notes: equivalent to `make check`; running `make` alone is the same.

### make check

Verifies that the machine has every declared tool and application.

Parameters: none.

Errors: exits non-zero at the first missing item and does not report the
rest.

Notes: runs `check_package_versions`, `check_os_version`, and
`check_desktop`, in that order.

### make check_desktop

Verifies the desktop applications that `README.md` declares.

Parameters: none.

### make check_os_version

Verifies that the machine runs Ubuntu 26.04 LTS.

Parameters: none.

### make check_package_versions

Verifies the version of every command-line tool that the playbook installs.

Parameters: none.

### make setup_client

Installs the declared tools on the local machine.

Parameters: none.

Errors: fails when sudo asks for a password, or when the inventory has no
localhost entry.

### make setup_server

Installs the declared tools on `islasgeci.dev`.

Parameters: none.

Errors: fails when Ansible cannot escalate privileges, which happens on
Ubuntu 26.04 without passwordless sudo.

Notes: the documented setup does not call this target. The dotfiles alias
`init-devserver` runs the playbook directly.
