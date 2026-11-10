# Chapter 2: Basic Commands and Directory Hierarchy

Book p.11–46 (PDF p.37–72) · 21 sections · split into 7 lessons

| Lesson | Sections | PDF pages |
|---|---|---|
| 1 | intro, 2.1 Bourne shell, 2.2 Using the shell, 2.3 Basic commands | 37–42 |
| 2 | 2.4 Navigating directories, 2.5 Intermediate commands | 42–48 |
| 3 | 2.6–2.13 Password/shell, dot files, variables, PATH, special chars, editing, editors, help | 48–54 |
| 4 | 2.14 Shell input/output, 2.15 Error messages | 54–58 |
| 5 | 2.16 Processes & job control | 58–61 |
| 6 | 2.17 File permissions & symlinks (+ project task) | 61–65 |
| 7 | 2.18 Archiving, 2.19 Directory hierarchy, 2.20 sudo, 2.21 | 65–72 |

---

## Lesson 1: The shell and basic commands (intro, 2.1–2.3, PDF p.37–42)

### Why "Unix" commands?
- **Linux is a Unix flavour at heart.** These commands also work on BSD and macOS.
- Knowing core commands helps you adapt to new Linux releases, and **many commands map directly to system calls** (Chapter 1).
- The book flags **Section 2.19 (directory hierarchy)** as must-read even for experienced users.

### 2.1 The Bourne shell: /bin/sh
- A **shell** = a program that **runs commands** (other programs or its own built-ins). It is also a small **programming environment**.
- Many system parts are **shell scripts** (text files of shell commands). Chapter 11.
- Easy to fix mistakes: you can see what you typed and try again.
- All Unix shells come from the **Bourne shell (`/bin/sh`)**, made at Bell Labs. Every Unix system needs one.
- Linux uses **bash** ("Bourne-again shell"), which is the default on most distributions. Change shell with `chsh`.

**Real output, both nodes:**
```
$ echo $SHELL
/bin/bash                          ← my login shell is bash (Pi and VM)

$ ls -l /bin/sh
lrwxrwxrwx 1 root root 4 ... /bin/sh -> dash    ← Pi and VM
```
⚠️ **Book vs reality:** the book says `/bin/sh` is normally a link to bash. On **Ubuntu (both my machines) it points to `dash`**, a smaller, faster Bourne-compatible shell used for system scripts. My interactive shell is still bash. Lesson: check the actual system instead of assuming.

### 2.2 Using the shell
- Log in as a **regular user** for daily work, not root.
- **Prompt** on Ubuntu: `name@host:path$` (Fedora: `[name@host path]$`).
  - Pi: `rabindrakunwar@rabindrakunwar:~$` · VM: `ubuntu@bot-vnic:~$`
- In the book, `$` = type as a normal user. **`#` = run as root** (use `sudo`). Don't type the `$` or `#`.
- **Command structure:** `program argument argument ...`
  - `cat /etc/passwd`: program `cat`, one argument `/etc/passwd`.
  - **Options** are arguments that change behaviour and usually start with `-` (e.g. `ls -l`).
  - Exceptions: shell built-ins, temporary environment variables.

```
$ head -3 /etc/passwd              ← same on both nodes
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```
(The `/etc/passwd` format is covered in Chapter 7. Note root's UID `0` from Chapter 1.)

#### 2.2.2 cat
- `cat file1 file2 ...` prints files one after another. The name comes from con**cat**enate.

#### 2.2.3 Standard input and standard output
- Processes read from **input streams** and write to **output streams**. A stream's source or destination can be a file, a device, a terminal, or **another process**.
- `cat` with **no file** reads **standard input (stdin)**, which is your keyboard/terminal. It echoes each line back.
- **`Ctrl-D`** on an empty line = **EOF (end of file)**: "no more input", which ends `cat`.
- **`Ctrl-C`** = terminate the program regardless. Don't mix them up.
- **Standard output (stdout)** = where a process writes output; by default the terminal.
- A third stream, **standard error (stderr)**, comes in 2.14.
- These are the file descriptors from my strace runs: **0 = stdin, 1 = stdout, 2 = stderr**.
- Streams can be redirected to files and other processes (2.14).

### 2.3 Basic commands

| Command | Does | Example |
|---|---|---|
| `ls` | list a directory (default: current) | `ls -l` long listing, `ls -F` shows type (`/` = directory, `*` = executable) |
| `cp` | copy | `cp file1 file2` · `cp file dir` · `cp f1 f2 f3 dir` |
| `mv` | move **or rename** | `mv file1 file2` (rename) · `mv file dir` |
| `touch` | create an empty file, or update the timestamp of an existing one | `touch file` |
| `rm` | delete a file. ⚠️ **No undo / recycle bin**, only backups | `rm file` |
| `echo` | print its arguments | `echo Hello again.` |

### Q: what does `rm reports` do on a directory? (tested on both nodes)
```
$ rm reports
rm: cannot remove 'reports': Is a directory      ← refused; exit code 1 (error)

$ rmdir reports                                  ← works only if the directory is EMPTY (exit code 0)

$ rmdir reports        (with a file inside)
rmdir: failed to remove 'reports': Directory not empty

$ rm -r reports                                  ← -r = recursive: deletes the folder AND everything inside, silently
```
| Command | Deletes |
|---|---|
| `rm file` | a file |
| `rmdir dir` | an **empty** directory (safe: refuses if anything is inside) |
| `rm -r dir` | a directory **and all its contents**. ⚠️ No confirmation, no undo |
| `rm -ri dir` | the same, but **asks before each file** (`-i` = interactive) |

- Plain `rm` refuses directories on purpose, as a safety net.
- ⚠️ `rm -rf` (`-f` = force, never ask) is the most dangerous command in Linux. Check the prompt (`hostname`) and the path (`pwd`) first.
- Exit code: `0` = success, non-zero = error (echo `$?` right after a command to see it).
- On the VM the error line appeared *after* "exit code: 1" in my test: errors go to **stderr** and normal output to **stdout**, two separate streams that can arrive out of order over SSH. Lesson 4.

**Reading `ls -l`** (real, Pi):
```
-rw-rw-r-- 1 rabindrakunwar rabindrakunwar    6 Nov 10 00:07 notes.txt
drwxrwxr-x 2 rabindrakunwar rabindrakunwar 4096 Nov 10 00:07 reports
│          │ │              │              │    │            └ name
│          │ │              │              │    └ modification date/time
│          │ │              │              └ size (bytes)
│          │ │              └ group (column 4)
│          │ └ owner (column 3)
│          └ number of hard links (Section 4.6)
└ type + permissions (Section 2.17). First char: - = file, d = directory
```

**`touch` updates timestamps** (real):
```
00:07  touch empty.txt   → -rw-rw-r-- ... 0 Nov 10 00:07 empty.txt
00:08  touch empty.txt   → -rw-rw-r-- ... 0 Nov 10 00:08 empty.txt   ← same file, new time
```

**Side finding: time zones.** I ran the same lab at the same moment on both nodes:
- Pi showed `Nov 10 00:07` (Sydney time, AEDT)
- VM showed `Nov  9 13:07` (UTC)

Same instant, 11 hours apart on paper. Servers are usually kept on **UTC** so logs from different places line up. This matters for the time-sync pillar in trading-infra-lab.

### Interview answers
- **What is a shell?** "A program that runs commands: it parses what you type, runs programs (fork + exec) or built-ins, and is also a scripting language. bash is the default on most Linux systems."
- **stdin/stdout/stderr?** "The three standard streams every process gets: file descriptors 0, 1 and 2. By default they're connected to the terminal, but they can be redirected to files or piped to other processes."
- **Ctrl-C vs Ctrl-D?** "Ctrl-C interrupts/kills the running program; Ctrl-D sends end-of-file to say there's no more input."
- **How do you rename a file?** `mv old new`. There's no separate rename command for this.

### Lesson 1 quiz: what I got wrong at first
- **Rename** `a.txt` → `b.txt`: I wrote `cp a.txt b.txt`. That **copies** (now 2 files). Rename = **`mv a.txt b.txt`** (the old name disappears). Trick: renaming = moving to a new name.
- Retry typo: `mv sraft.txt final.txt` → would fail with `No such file or directory`. **Use Tab completion:** type `mv dr` + **Tab** and the shell fills in `draft.txt`, so no typos (Section 2.11).
