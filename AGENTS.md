# Thin client for remote development

Provisions an Ubuntu 26.04 laptop to work against the shared development
server at `islasgeci.dev`. The repository holds one Ansible playbook, one
Makefile, and the documents that declare what a client must have.

## Who this is for

The user sets up a laptop for the first time. They copy and paste commands
and cannot write a playbook, a Makefile target, or a script. Every documented
command must be complete and safe to paste verbatim.

The maintainer writes and owns the playbook, the Makefile, and the
documentation, and diagnoses failures. Do not write instructions that assume
the user can debug them.

## The public interface

The public interface is the Makefile. Its seven targets are the outermost
surface the user consumes: `all`, `check`, `check_desktop`,
`check_os_version`, `check_package_versions`, `setup_client`, and
`setup_server`. `DOCS.md` lists them and nothing else. `CHANGELOG.md`
records only changes to them. The playbook, the inventory, and the documents
themselves are not interface.

## Verification

There are no tests. Verification is `make check`, which needs a provisioned
client and stops at the first missing item. Check the playbook by itself
with `ansible-playbook --syntax-check ansible/development.yml`.

## Commands

- `make` runs `check`.
- `make setup_client` provisions `localhost`.
- `make check` runs every `check_*` target.
- `ansible-playbook ansible/development.yml --limit islasgeci.dev`
  provisions the server; the dotfiles alias `init-devserver` calls this
  directly instead of `make setup_server`.

## Conventions

- The playbook installs headless tools only, because it also runs on a server
  with no display. Graphical software, fonts, and input methods belong in
  `README.md` with the user procedure, and in the `check_desktop` target.
  Adding or removing one means editing both.
- The inventory is `/etc/ansible/hosts`, outside the repository, and the
  group `development` holds both hosts. `--limit` chooses which one runs.
- Version checks are grep patterns over each command's output, so every
  pattern matches the format that tool prints.
- Tools installed from snap pin the major version only, or assert presence,
  because snaps refresh themselves.
- Removing a task does not uninstall anything from a machine that already ran
  it.
- `ansible-core`, `git`, `make`, and the inventory are manual prerequisites,
  not provisioned.
- The inventory reads `DEVSERVER_SUDO_PASSWORD` from the environment, which
  dotfiles loads from the vault. Without it, the server host line cannot
  escalate privileges.
- The R `languageserver` install compiles from source and can exceed five
  minutes.
- Ubuntu 26.04 ships `sudo-rs`, which requires a TTY for password
  authentication and breaks Ansible `become`. See `TODO.md`.
