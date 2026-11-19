# Backlog

- [ ] Document the `ansible_python_interpreter` pin for `/etc/ansible/hosts` so the last playbook warning clears — `README.md`.
  Test: `ansible-playbook ansible/development.yml --limit localhost` prints no discovered-interpreter warning.
- [ ] Add `r-base-dev` to the package check, as the playbook installs it — `Makefile`.
  Test: `grep -q r-base-dev Makefile` succeeds.
