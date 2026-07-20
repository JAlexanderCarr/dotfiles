# Shell Configuration

## Prompt

The Zsh prompt (`~/.zshrc`) shows Git branch, Kubernetes context/namespace, command execution time, and a right-justified clock.

## Aliases (`~/.aliases`)

**Git:**

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gc` | `git commit -s` |
| `gca` | `git commit -s --amend` |
| `gch` | `git checkout` |
| `gb` | `git branch` |
| `gfp` | `git push --force-with-lease` (blocked by Claude Code hooks — run manually if needed) |
| `gpu` | `git push -u origin <current-branch>` |
| `gr` | `git rebase -i` |

**kubectl:**

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kn` | `kubens` |
| `kx` | `kubectx` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get services` |
| `kgd` | `kubectl get deployments` |

**Other:**

| Alias | Command |
|-------|---------|
| `py` | `python3` |
| `ll` | `ls -alF` |
| `la` | `ls -A` |

## Environment Overrides

`EDITOR`/`VISUAL` default to `nvim` if it's installed, else `vi` (`~/.profile`). The shell profile also sources `~/.env` if it exists — use it for machine-local env vars not tracked by chezmoi:

```sh
export AWS_PROFILE=myprofile
export EDITOR=code
```

## Git Configuration

`~/.gitconfig` is templated with your personal details and sets:

- Default branch: `main`, remote: `origin`, pull strategy: rebase
- Commit signing: SSH (configured signing key)
- Editor: `nvim`
- `fetch.prune`, `rerere.enabled`, `diff.algorithm = histogram`, `merge.conflictstyle = zdiff3`

There is no URL rewrite — git uses whatever the remote URL specifies, so either an HTTPS token or an SSH key works unmodified.

## SSH Key Bootstrap

`chezmoi init` optionally prompts to generate an ed25519 SSH key for GitHub (defaults to off). If enabled, it creates `~/.ssh/<name>` (default `id_github`, matching the default signing key) if one doesn't already exist, and wires it into a `github.com` block in `~/.ssh/config`. The public key and GitHub registration steps are printed at the very end of `chezmoi apply`'s output.

## tmux

`~/.tmux.conf` sets mouse support, vi-style copy-mode, truecolor passthrough, a larger scrollback, and a status line matching the shell prompt's palette (yellow git branch, green host).

## Readline (bash)

`~/.inputrc` makes bash's tab completion case-insensitive and hyphen/underscore-insensitive, shows all matches on an ambiguous completion instead of just ringing the bell, and filters up/down arrow history search by what's already typed.
