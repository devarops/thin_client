# Lightweight client for remote development

## What it does

Turns a fresh Ubuntu 26.04 laptop into a client that works against the team's
development server. It installs the tools the team uses, adds the desktop
applications the team requires, and checks that the machine is ready.

## Usage

Run the setup target once, then the check target to confirm the machine is
ready:

```shell
make setup_client
make check
```

The targets and what they do are listed in [DOCS.md](DOCS.md). The desktop
applications are listed under [Desktop applications](#desktop-applications).

## Before you start

You need a laptop with Ubuntu 26.04 LTS, access to the `devarops`
repositories on GitHub, and the team vault document, which a maintainer
shares with you.

1. Create your SSH key with `ssh-keygen`.
1. Add your public SSH key to
   [Bitbucket](https://bitbucket.org/account/settings/ssh-keys/) and
   [GitHub](https://github.com/settings/keys/)
1. Add your key to the agent so it can be forwarded:
    - On Linux, run `ssh-add ~/.ssh/id_ed25519`
    - On WSL, add this to `~/.bashrc`:
    ```shell
    eval `ssh-agent -s`
    ssh-add ~/.ssh/id_ed25519
    ```
1. Let your user run `sudo` without a password:
    ```shell
    sudo update-alternatives --config editor
    sudo visudo -f /etc/sudoers.d/evaro
    ```
    Add this line to the file:
    ```
    evaro ALL=(ALL) NOPASSWD: ALL
    ```
1. Install Ansible, Git, and Make:
    ```shell
    sudo apt update && sudo apt install --yes ansible-core git make
    ```
1. Create `/etc/ansible/hosts` with this content:
    ```shell
    [development]
    islasgeci.dev ansible_host=islasgeci.dev ansible_user=evaro ansible_become_password="{{ lookup('env', 'DEVSERVER_SUDO_PASSWORD') }}"
    localhost ansible_connection=local
    ```

## Run the project

There is no containerised path: the setup runs directly on the laptop.

1. Clone the repository and provision the machine:
    ```shell
    mkdir --parents ~/repositorios/
    cd ~/repositorios/
    git clone git@github.com:devarops/thin_client.git
    cd thin_client
    make setup_client
    ```
1. Restart the terminal.
1. Install the desktop applications described under
   [Desktop applications](#desktop-applications).
1. Confirm the machine is ready:
    ```shell
    cd ~/repositorios/thin_client
    make check
    ```
1. Install [dotfiles](https://github.com/devarops/dotfiles):
    ```shell
    cd ~/repositorios/
    git clone git@github.com:devarops/dotfiles.git
    cd dotfiles
    make install
    ```
1. Add your [secret vault](https://docs.google.com/document/d/1lY7ycXs4J8wp1OyJCmPsvfB7YdQqscqL52cIZxBP6Rw/).
1. Copy your credentials to the development server and configure it from
   your laptop: `devserver-init`[.](https://github.com/devarops/dotfiles/blob/develop/.bash_aliases#L12)
1. Enter the development server with:
   `ssh devserver`[.](https://github.com/devarops/dotfiles/blob/develop/.ssh/config)

## Desktop applications

Install these during step 3. `make check` fails if any of them is missing.

### Ghostty

Terminal emulator built with GTK 4 and libadwaita. Install it from the snap:
it is the only source of current releases for Ubuntu 26.04, whose archive
ships an older version on its own schedule.

```shell
sudo snap install ghostty --classic
```

The snap refreshes itself, so the check pins the major version only.

Make it the default terminal in GNOME Settings, or launch it from the
application grid. Ptyxis is the distribution default and can stay installed.

### Slack

Slack is a desktop client, installed from Slack's own apt repository.

```shell
curl --fail --silent --show-error --location \
  https://packagecloud.io/slacktechnologies/slack/gpgkey \
  | sudo gpg --dearmour --output /usr/share/keyrings/slack-desktop.gpg
echo "Types: deb
URIs: https://packagecloud.io/slacktechnologies/slack/debian/
Suites: jessie
Components: main
Signed-By: /usr/share/keyrings/slack-desktop.gpg" \
  | sudo tee /etc/apt/sources.list.d/slack.sources
sudo apt update && sudo apt install --yes slack-desktop
```

The repository tracks the same releases as the snap, shipped by Slack
itself. A laptop that already has the snap must remove it, so the package
manager owns the only copy:

```shell
sudo snap remove slack
```

The check pins only the major version, because Slack ships weekly and the
repository always carries the current one.

### Flameshot

Screenshot tool with annotation, installed from the snap.

```shell
sudo snap install flameshot
```

Wayland does not let an application read the screen. Flameshot asks the
screenshot portal, and the portal answers only after the permission is
granted once. Without it every capture ends with `Unable to capture screen`:

```shell
dbus-send --session --dest=org.freedesktop.impl.portal.PermissionStore \
  /org/freedesktop/impl/portal/PermissionStore \
  org.freedesktop.impl.portal.PermissionStore.SetPermission \
  string:'screenshot' boolean:true string:'screenshot' \
  string:'snap.flameshot' array:string:'yes'
```

Launch it from the application grid or the tray icon. The snap refreshes
itself, so the check pins the major version only.

### Voxtype

Push-to-talk dictation from the focused window. It transcribes on the local
machine and types the result with `ydotool`, which needs access to the
kernel's input devices.

```shell
curl --fail --location --remote-name \
  https://github.com/peteonrails/voxtype/releases/download/v1.3.0/voxtype_1.3.0-1_amd64.deb
sudo apt install --yes ./voxtype_1.3.0-1_amd64.deb
sudo apt install --yes ydotool
sudo usermod --append --groups input "$USER"
```

Log out and back in, so the new group membership applies, then enable the
services and select the GPU backend:

```shell
systemctl --user enable --now ydotool
sudo voxtype setup gpu --enable
systemctl --user enable --now voxtype
```

`voxtype setup gpu --status` reports the backend in use and the GPUs it
found. The package ships no model, so download one and select it:

```shell
voxtype setup --download --model medium
cp /etc/voxtype/config.toml ~/.config/voxtype/config.toml
voxtype setup model --set medium --restart
```

The package writes a system-wide default to `/etc/voxtype/config.toml` that
names the `base.en` model, which it does not ship. Voxtype reads your own
`~/.config/voxtype/config.toml` when one exists, so the copy is your starting
point and `--set` makes it point at the downloaded model. Without those two
commands the download alone leaves `voxtype doctor` failing on the missing
`base.en` model.

Hold <kbd>ScrollLock</kbd> while you speak and release it to transcribe. The
settings live in `~/.config/voxtype/config.toml`. The check accepts any `1.x`
release, so an upgrade replaces the URL with the newer one; it also runs
`voxtype doctor`, which passes only while the configured model is downloaded.

### Emoji picker

The emoji picker is `ibus-typing-booster`, from the Ubuntu archive. It
provides completion and emoji input for the IBus input method.

```shell
sudo apt update && sudo apt install --yes ibus-typing-booster
```

Log out and back in, or run `ibus restart`, before the input method appears
in the keyboard menu.

### Nerd Fonts

Install at least one Nerd Font per user. Terminal and editor glyphs depend on
it; the theme and prompt assume it is present.

This setup installs the Hack Nerd Font from the pinned nerd-fonts release.

```shell
mkdir --parents ~/.local/share/fonts
curl --location --output /tmp/Hack.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
unzip -o /tmp/Hack.zip -d ~/.local/share/fonts/Hack
fc-cache --force
```

Fonts already installed under `~/.fonts` satisfy the check too.
