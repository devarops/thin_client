# Backlog

- [ ] Refresh the pinned Ghostty terminal information when the snap updates it — `ansible/files/xterm-ghostty.terminfo`.
  Test: `infocmp -x xterm-ghostty | diff - ansible/files/xterm-ghostty.terminfo` prints nothing.
