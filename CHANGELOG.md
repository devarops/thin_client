# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `make check_desktop` verifies Flameshot 15 and Voxtype 1, the screenshot and
  dictation applications that `README.md` declares.

### Changed

- `make check_package_versions` is now `make check_terminal`, which names the
  layer it verifies: the tools that run without a display.
- `make check_terminal` requires Node 24 and npm 11, the versions Ubuntu 26.04 ships.
- `make setup_client` installs OpenCode 2 instead of OpenCode 1.

## [0.1.0] - 2026-10-30

### Changed

- `make check_package_versions` accepts any Neovim 0.x version instead of requiring 0.12, because the snap updates on its own.
- `make check_desktop` looks for the Debian package of Slack instead of the snap, because Slack publishes the same releases to its own apt repository.

### Removed

- `make setup_server`. The dotfiles alias `init-devserver` already ran the same playbook directly, so the target duplicated it without being reachable from the documented setup.

### Added

- Documentation of the Makefile targets that form the public interface.

[Unreleased]: https://github.com/devarops/thin_client/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/devarops/thin_client/releases/tag/v0.1.0
