# Git cheat sheet

## The idea
Git keeps a **history of snapshots** of a folder. GitHub is a **copy of that history online**.

```
 working folder  ──git add──►  staging area  ──git commit──►  local history  ──git push──►  GitHub
 (files I edit)               ("in the box")                 (snapshot saved)             (online copy)
```

📦 **Parcel analogy**
- `git add` = put items **in the box**
- `git commit -m "..."` = **seal the box** and write a label on it
- `git push` = **post it** to GitHub

## My two repos
| Repo | Folder on the Pi | GitHub |
|---|---|---|
| linux-homelab (study notes) | `~/linux-project` | github.com/rbkunwar/linux-homelab |
| trading-infra-lab (project) | `~/linux-project/trading-infra-lab` | github.com/rbkunwar/trading-infra-lab |

**`cd` into the right folder first.** Git works on the repo you're standing in.

## The everyday routine
```bash
cd ~/linux-project          # 1. go to the repo
git status                  # 2. what changed?
git diff                    # 3. see the exact changes (q to quit)
git add notes/ch02-basic-commands.md progress.md   # 4. put files in the box
git status                  # 5. check: files are now green ("to be committed")
git commit -m "Ch2 Lesson 2: paths, grep, find"     # 6. seal with a label
git push                    # 7. send to GitHub
git log --oneline -5        # 8. see the last 5 commits
```

`git add -A` adds **everything** that changed. Fine when `git status` shows only files you expect.

## Reading `git status`
| You see | Meaning |
|---|---|
| `Untracked files:` (red) | new file Git has never seen; `git add` it |
| `Changes not staged for commit:` (red) | edited, not in the box yet |
| `Changes to be committed:` (green) | in the box, ready to commit |
| `nothing to commit, working tree clean` | everything is saved |
| `Your branch is ahead of 'origin/main' by 1 commit` | committed but **not pushed** yet; run `git push` |
| `Your branch is up to date with 'origin/main'` | GitHub has everything ✅ |

## Good commit messages
- Short, says **what** changed: `Ch2 Lesson 2: grep, find, head/tail`
- Not: `update`, `stuff`, `asdf`
- Recruiters can read my commit history, so keep it professional.

## Safety rules
- **Run `git status` before every commit.** Know what you're sending.
- **Never commit** private keys, passwords, tokens, IP addresses, or personal data. The repos are **public**.
- `.gitignore` lists files Git must ignore (e.g. the book PDF, `*.key`).
- Made a typo in the last message (not pushed yet)? `git commit --amend -m "better message"`.
- Added a file by mistake (not committed yet)? `git restore --staged <file>`.

## When something goes wrong
| Error | Fix |
|---|---|
| `fatal: not a git repository` | wrong folder; `cd ~/linux-project` |
| `nothing to commit` | you forgot `git add`, or nothing changed |
| `rejected ... fetch first` | GitHub has commits you don't have; run `git pull`, then `git push` |
| `Please tell me who you are` | identity missing; already set in both repos, so ask Claude |
