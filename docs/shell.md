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
| `gfp` | `git push --force-with-lease` |
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

The shell profile sources `~/.env` if it exists — use it for machine-local env vars not tracked by chezmoi:

```sh
export AWS_PROFILE=myprofile
export EDITOR=code
```

## Git Configuration

`~/.gitconfig` is templated with your personal details and sets:

- Default branch: `main`, remote: `origin`, pull strategy: rebase
- Commit signing: SSH (configured signing key)
- Editor: `nvim`
- GitHub HTTPS URLs rewritten to SSH
