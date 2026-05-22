# TODO — `make setup_server` Failure: Privilege Escalation Timeout

## Problem

Running `make setup_server` (which executes `ansible-playbook ansible/development.yml --limit islasgeci.dev`) failed with:

```
TASK [Install batcat]
[ERROR]: Task failed: Timeout (12s) waiting for privilege escalation prompt
fatal: [islasgeci.dev]: UNREACHABLE!
```

### Symptoms

| Attempt | Result |
|---|---|
| `make setup_client` (localhost) | ✅ Success |
| `make setup_server` (islasgeci.dev) | ❌ Timeout on first `become: true` task |

SSH connectivity worked fine: the "Gathering Facts" task completed successfully on the remote host. The failure occurred exclusively when Ansible tried to escalate privileges via `become: true`.

### Investigation

1. **SSH connection** to `evaro@islasgeci.dev` works without issues.

2. **The `DEVSERVER_SUDO_PASSWORD` environment variable** was set. However, the password is *correct* — the issue was not a wrong password, but the mechanism by which Ansible delivers it.

3. **The remote server runs Ubuntu 26.04 "Resolute Raccoon"**, which ships with **`sudo-rs`** (version `0.2.13-0ubuntu1`) — a Rust reimplementation of `sudo` — instead of the traditional `sudo` package.

4. **`sudo-rs` requires a TTY for password authentication.** Unlike traditional `sudo`, which can interact with password prompts over a non-TTY SSH channel (via the `-S` flag or through Ansible's become plugin), `sudo-rs` refused to authenticate without a pseudo-terminal attached:

    ```
    $ ssh evaro@islasgeci.dev 'sudo -n whoami'
    sudo: interactive authentication is required

    $ ssh evaro@islasgeci.dev 'echo "$DEVSERVER_SUDO_PASSWORD" | sudo -S whoami'
    sudo: Authentication failed
    ```

    However, the password **does** work when a PTY is forced:

    ```
    $ ssh -t evaro@islasgeci.dev 'sudo whoami'
    # (prompts for password, the correct password is accepted → root)
    ```

5. **Ansible's `become` plugin** uses a non-TTY SSH channel to run commands. It cannot force PTY allocation for the `sudo` subprocess, so it waited 12 seconds for a password prompt from `sudo-rs` that never arrived, then timed out.

6. **There is no `Defaults requiretty`** in `/etc/sudoers` or its included fragments — `sudo-rs` does not support that setting (`visudo -c` rejects `!requiretty` as "unknown setting"). The TTY requirement is apparently a hardcoded behavior of `sudo-rs` when a password is required.

### Key Difference: Client vs. Server

| Aspect | `localhost` | `islasgeci.dev` |
|---|---|---|
| Connection type | `ansible_connection: local` | SSH as `evaro` |
| Sudo implementation | Traditional `sudo` (or passwordless) | `sudo-rs` 0.2.13 |
| Password required | No (passwordless sudo) | Yes |
| TTY requirement | N/A | Hard requirement of `sudo-rs` |
| Result | ✅ Works | ❌ Timeout |

### Fix Applied (Temporary)

On the remote server, I created a sudoers drop-in file `/etc/sudoers.d/evaro`:

```
evaro ALL=(ALL:ALL) NOPASSWD:ALL
```

This grants the `evaro` user **passwordless sudo**, which bypasses `sudo-rs`'s TTY requirement entirely — if no password is needed, there's nothing to prompt for.

**Verification:** after applying the fix:

```
$ ssh evaro@islasgeci.dev 'sudo -n whoami'
root

$ make setup_server
# All 16 tasks completed successfully.
# (The R 'languageserver' package install timed out after 5 min,
#  but that is a compile-time issue, not the privilege escalation problem.)
```

## Status

- **Root cause identified:** `sudo-rs` on Ubuntu 26.04 requires a TTY for password-based authentication, which is incompatible with Ansible's default non-TTY become mechanism.
- **Temporary fix applied:** Passwordless sudo for `evaro` on the server.
- **Limitation:** The server is destroyed daily, so this fix needs to be re-applied after every rebuild.

## Next Steps — Discussion Needed

We need to decide where to make this fix permanent:

1. **In this repo (`thin_client`):** Add automation to the `Makefile` or Ansible playbook to configure passwordless sudo for `evaro` as part of `setup_server`. This would re-apply the fix on every provisioning run.

2. **In a separate repo (`../development_server_setup`):** Move the server-provisioning logic (including user setup and sudo configuration) into its own repository that `thin_client` depends on or references. This would be the cleaner separation of concerns, keeping "server setup" concerns out of the "client dev environment" repo.

3. **Alternative approaches to consider:**
   - Configure Ansible to force PTY allocation (e.g., `ansible_ssh_common_args: '-tt'`).
   - Replace `sudo-rs` with traditional sudo on the server image.
   - Use `ansible_become_method: su` or a different become plugin.

**Proposed action:** Discuss and decide on the approach, then implement the permanent fix in the chosen repository.
