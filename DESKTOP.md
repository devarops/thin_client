# Thin client desktop applications

Software a thin client needs beyond what `ansible/development.yml` provides.

The playbook owns headless tools: everything it installs runs on the
development server as well as on a client. This file owns the rest —
software that needs a graphical session, a font stack, or an input method,
and that a server can neither display nor use.

Every entry below is team policy. `make check` verifies each one through its
`check_desktop` target, so a client without these is not a finished client.

## Ghostty

Terminal emulator built with GTK 4 and libadwaita. Install it from the snap:
it is the only source of current releases for Ubuntu 26.04, whose archive
ships an older version on its own schedule.

```shell
sudo snap install ghostty --classic
```

The snap refreshes itself, so the check pins the major version only.

Make it the default terminal in GNOME Settings, or launch it from the
application grid. Ptyxis is the distribution default and can stay installed.

## Slack

Desktop client, from the snap published by Slack.

```shell
sudo snap install slack
```

Machines provisioned before this policy may carry the `slack-desktop` Debian
package instead. Remove it first, because `/usr/bin` precedes `/snap/bin` in
the default path and the old binary would keep winning:

```shell
sudo apt remove --yes slack-desktop
```

Slack updates itself weekly, so the check asserts presence rather than a
version we cannot meaningfully hold.

## Emoji picker

`ibus-typing-booster`, from the Ubuntu archive. It provides completion and
emoji input for the IBus input method.

```shell
sudo apt update && sudo apt install --yes ibus-typing-booster
```

Log out and back in, or run `ibus restart`, before the input method appears
in the keyboard menu.

## Nerd Fonts

Hack Nerd Font, installed per user from the pinned nerd-fonts release.
Terminal and editor glyphs depend on it; the theme and prompt assume it is
present.

```shell
mkdir --parents ~/.local/share/fonts
curl --location --output /tmp/Hack.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
unzip -o /tmp/Hack.zip -d ~/.local/share/fonts/Hack
fc-cache --force
```

Fonts already installed under `~/.fonts` satisfy the check too.

## Verification

```shell
make check_desktop
```

The target fails if any application is missing, and `make check` depends on
it, so the full verification covers both layers: the Ansible tools and the
desktop applications.
