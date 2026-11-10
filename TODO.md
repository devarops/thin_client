# Backlog

- [ ] Make the R `languageserver` task install the package and run only once — `ansible/development.yml`.
  Test: `Rscript -e 'find.package("languageserver")'` prints a path on the server, and a second consecutive run reports that task as ok.
- [ ] Replace the `ansible_env.HOME` references with `ansible_facts` — `ansible/development.yml`.
  Test: A playbook run prints no `INJECT_FACTS_AS_VARS` warning, and grep finds no `ansible_env` in `ansible/development.yml`.
- [ ] Refresh the pinned Ghostty terminal information when the snap updates it — `ansible/files/xterm-ghostty.terminfo`.
  Test: `infocmp -x xterm-ghostty | diff - ansible/files/xterm-ghostty.terminfo` prints nothing.
