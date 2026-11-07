# linux-homelab

My journey from beginner to Linux engineer, learning hands-on on a home lab.

## The lab

| Machine | OS | Role |
|---|---|---|
| Raspberry Pi 4 (4 GB, USB boot) | Ubuntu 26.04 | Main lab box, local practice |
| Cloud VM | Ubuntu 24.04 | Remote server practice over SSH |

`dual-terminal.sh` opens a tmux session with the Pi on top and the VM below:

```bash
./dual-terminal.sh          # start or reattach
./dual-terminal.sh status   # show panes
./dual-terminal.sh stop     # close the session
```

## Study plan

Main book: **How Linux Works, 3rd Edition** by Brian Ward (No Starch Press, 2021), plus extra job skills the book doesn't cover (Red Hat systems, Docker, Ansible, Git, nginx, security hardening).

Every section follows the same loop: **Learn → Lab → Check → Interview angle.**

Progress checklist and session log: **[progress.md](progress.md)**

## Repo layout

```
progress.md        checklist of every book section + session log
dual-terminal.sh   tmux Pi + VM split terminal
notes/             my notes, one file per chapter (added as I go)
labs/              hands-on exercises and scripts
```

The book itself is not in this repo (it's copyrighted). Get your own copy from No Starch Press.
