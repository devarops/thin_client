# Thin client for remote development

Provisions an Ubuntu 26.04 laptop to work against the shared development
server at `islasgeci.dev`. The repository holds one Ansible playbook, one
Makefile, and the documents that declare what a client must have.

## Writing the documentation

- Every documented command must be complete and safe to paste verbatim.
- Do not write instructions that assume the reader can debug them.
- Every `TODO.md` item carries a `Test:` line that fails while the item is open, and names files, not line numbers.

## The public interface

The public interface is the Makefile. It is the outermost surface the user
consumes, and `DOCS.md` lists its elements and nothing else. `CHANGELOG.md`
records only changes to those elements. The playbook, the inventory, and the
documents themselves are not interface.

## Version 1.0.0 release conditions

Release 1.0.0 the first time `ansible/development.yml` runs without warnings
and a second consecutive run changes nothing. Neither run prints `WARNING` or
`DEPRECATION WARNING`, and the second play recap reports `changed=0`.

The only warning left is the discovered Python interpreter, which
`/etc/ansible/hosts` must pin with `ansible_python_interpreter`; no repository
change clears it (commit `39025f1`).

## Verification

There is no test suite. Verification is `make check`, which needs a
provisioned client and stops at the first missing item. Check the playbook by
itself with `ansible-playbook --syntax-check ansible/development.yml`.

## Verifying the graphical applications

`make check` proves the graphical declarations are installed; it cannot prove
they work. Run these after the client is provisioned.

- Flameshot captures the screen:

  ```shell
  flameshot full -p ~/Pictures/probe.png
  test -s ~/Pictures/probe.png && rm ~/Pictures/probe.png
  ```

  The probe writes under `$HOME` because the snap cannot reach `/tmp`. A
  missing file, or `Unable to capture screen`, means the portal grant in
  `README.md` was skipped.
- Voxtype is healthy:

  ```shell
  voxtype doctor
  ```

  It exits non-zero when a check fails, and every `✗` line names its fix.
- The font resolves: `fc-match "Hack Nerd Font"` prints a `HackNerdFont` file.
- The input method is registered: `ibus list-engine | grep typing-booster`
  prints its line.
- Ghostty sees the font: `ghostty +list-fonts | grep -i nerd` prints at least
  one family.
- Slack has a session: open it once and confirm you are signed in to the
  workspace. No command observes this.

## Commands

- `ansible-playbook ansible/development.yml --limit islasgeci.dev`
  provisions the server; the dotfiles alias `devserver-init` is the
  documented way to run it.
- The server's instance, user accounts, and cron come from
  `IslasGECI/development_server_setup`; this playbook only adds tools.

## Conventions

- The playbook installs headless tools only, because it also runs on a server
  with no display. Graphical software, fonts, and input methods belong in
  `README.md` with the user procedure, and in the `check_desktop` target.
  Adding or removing one means editing both.
- The repository declares software and system infrastructure only: packages,
  GPU backends, groups, services, and a baseline model. Per-user configuration
  lives outside it, and no check reads a configuration file.
- The inventory is `/etc/ansible/hosts`, outside the repository, and the
  group `development` holds both hosts. `--limit` chooses which one runs.
- Tasks that only make sense on the server guard with
  `when: ansible_connection != 'local'`, because the play also runs on the
  laptop.
- The Ghostty `xterm-ghostty` terminfo entry is pinned in `ansible/files/` and
  installed system-wide on the server only, because `tmux` rejects Ghostty
  clients without it. Refresh the pin when the snap updates the entry.
- Version checks are grep patterns over each command's output, so every
  pattern matches the format that tool prints.
- Tools installed from snap pin the major version only, or assert presence,
  because snaps refresh themselves.
- Node comes from apt, never from snap: snap confinement made GitHub Copilot
  exit with code 1 (commit `35cbbd1`).
- Removing a task does not uninstall anything from a machine that already ran
  it.
- `ansible-core`, `git`, `make`, and the inventory are manual prerequisites,
  not provisioned.
- The inventory maps `ansible_become_password` to `DEVSERVER_SUDO_PASSWORD`,
  which dotfiles loads from the vault. The server's drop-in makes the
  password unnecessary, and `become` works with the variable unset.
- The R `languageserver` install compiles from source.
- The server gains passwordless sudo from
  `/etc/sudoers.d/sudo-group-nopasswd`, which `development_server_setup`
  writes (commit `e635cc7`). That file is why `become` works even though
  Ubuntu 26.04 ships `sudo-rs` and requires a TTY for password
  authentication.
