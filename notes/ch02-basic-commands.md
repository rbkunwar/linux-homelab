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

---

## Lesson 2: Navigating and intermediate commands (2.4–2.5, PDF p.42–48)

### 2.4 Paths
- The hierarchy starts at **`/` = the root directory**. The separator is `/` (not `\` like Windows).
- **Absolute path** = starts with `/`, e.g. `/usr/lib`. Works from anywhere.
- **Relative path** = doesn't start with `/`; relative to where you are now. Used most of the time.
- **`..`** = parent directory. In `/usr/lib`, `..` = `/usr` and `../bin` = `/usr/bin`.
- **`.`** = current directory. `./X11` = `X11` (most commands default to the current dir anyway).
- **`~`** = home directory (`/home/rabindrakunwar` on the Pi, `/home/ubuntu` on the VM).

My Day-1 mistake explained: `cd /linux-project` is absolute (looks for `/linux-project` at the disk root). Should be `cd ~/linux-project` or, from home, `cd linux-project`.

#### 2.4.1 cd
- **Current working directory** = the directory a process is "in". Each process has its own.
- `cd dir` changes it. `cd` alone → home.
- **`cd` is a shell built-in**, not a program. If it were a separate program (fork + exec), it would change **its own** directory and then exit, and the shell would stay put. A child can't change its parent's directory.
```
$ type cd                ← Pi and VM
cd is a shell builtin
$ type ls
ls is /usr/bin/ls        ← a real program on disk
```

#### 2.4.2–2.4.3 mkdir, rmdir, rm -r
- `mkdir dir` creates (`-p` = create parents too, no error if it exists).
- `rmdir dir` removes **only if empty**.
- `rm -r dir` removes recursively. ⚠️ **Never combine `-r` with globs like `*`**, and double-check before running, especially as root.

#### 2.4.4 Globbing (wildcards)
- The **shell** matches patterns against filenames and **replaces** the pattern with the matching names **before** running the command. This is called **expansion**.
- `*` = any number of characters (including none). `at*` starts with "at", `*at` ends with "at", `*at*` contains "at".
- `?` = exactly one character. `b?at` → `boat`, `brat`.
- **No match → no expansion**: the literal text is passed on.
- `'*'` in **single quotes** = don't expand. Needed for `grep` and `find` patterns.
- ⚠️ Windows habit `*.*` only matches names **containing a dot**. Use `*` for "all files".
- Globs don't match **dot files** (2.7).

```
$ echo /etc/host*                       ← Pi and VM
/etc/host.conf /etc/hostname /etc/hosts /etc/hosts.allow /etc/hosts.deny
$ echo /etc/*.conf | wc -w
33 (Pi)  35 (VM)                        ← number of .conf files in /etc
$ echo *dfkdsafh
*dfkdsafh                               ← no match: printed literally
$ echo '*'
*                                       ← quoted: not expanded
```

### 2.5 Intermediate commands

#### grep: print lines that match
| Usage | Does |
|---|---|
| `grep root /etc/passwd` | lines containing "root" |
| `grep root /etc/*` | search many files; prints the **filename** too |
| `grep -i` | ignore case |
| `grep -v` | **invert**: lines that do NOT match |
| `grep -c` | count matching lines |
| `grep -E` (= `egrep`) | extended regular expressions |

Regular expressions (more powerful than globs, different syntax):
- `.` = exactly one character
- `.*` = any number of characters, including none (like glob `*`)
- `.+` = one or more characters

```
$ grep root /etc/passwd
Pi:  root:x:0:0:root:/root:/bin/bash
     nm-openvpn:x:982:982:NetworkManager OpenVPN:/var/lib/openvpn/chroot:/usr/sbin/nologin   ← "root" inside "chroot"!
VM:  root:x:0:0:root:/root:/bin/bash
     snapd-range-524288-root:x:524288:...                                                    ← "root" inside a name
```
grep matches text **anywhere** in the line, not whole words (use `grep -w root` for whole words).

```
$ grep -c nologin /etc/passwd     → Pi 42, VM 31   (accounts that can't log in: system users)
$ grep -vc nologin /etc/passwd    → Pi 8,  VM 12   (accounts that CAN have a shell, or use /bin/false etc.)
```

#### 🔐 Real-world grep: who is attacking my VM? (security log `/var/log/auth.log`)
I can read it without sudo because I'm in group **`adm`** (Chapter 1 groups in action).
```
$ grep -c 'Accepted' /var/log/auth.log                         → Pi 269, VM 61    (successful logins)
$ grep -cE 'Failed password|Invalid user' /var/log/auth.log    → Pi 0,   VM 847   (failed attempts)

$ grep -oE 'Invalid user [^ ]+' /var/log/auth.log | awk '{print $3}' | sort | uniq -c | sort -rn | head -5
    327 admin
    140 user
    124 user2
     13 test
     13 deploy
```
- The VM is on the **public internet**, so bots from **61 different IPs** tried usernames like `admin` and `test` in about 2.5 days (since the log rotated on Nov 8). The Pi is only on my home network, so it has 0.
- They all failed: the VM has `passwordauthentication no` (keys only), so password guessing **can't work**. All 62 successful VM logins were mine, by key.
- Hardening ideas for trading-infra-lab pillar 1: `PermitRootLogin no` (currently `without-password`), fail2ban, firewall review (ufw is active).
- Logs **rotate**: `auth.log` (current), `auth.log.1` (last week), `auth.log.2.gz` ... (older, compressed). Section 2.18 + Chapter 7.

#### less: page through big output
- `less file` · **Space** = next page · **b** = back · **q** = quit
- `/word` search forward · `?word` search backward · **n** = next match
- Pipe output into it: `grep ie /usr/share/dict/words | less` (pipes `|`: Section 2.14)
- `less` is the improved version of the older `more`.

#### pwd: print working directory
- Needed when the prompt doesn't show the path, and with **symbolic links**:
```
$ cd /bin; pwd; pwd -P        ← Pi and VM
/bin
/usr/bin                      ← -P shows the REAL path: /bin is a symlink to /usr/bin
```

#### diff: differences between text files
- `diff file1 file2`. `diff -u` = "unified" format, preferred for sending to others and for tools (it's what Git shows).

#### file: guess a file's type
```
$ file /usr/bin/ls /etc/passwd /bin/sh /etc
Pi: /usr/bin/ls: symbolic link to ../lib/cargo/bin/coreutils/ls     ← Rust coreutils (same as cat)
VM: /usr/bin/ls: ELF 64-bit LSB pie executable, x86-64, ...        ← classic compiled program
    /etc/passwd: ASCII text
    /bin/sh:     symbolic link to dash
    /etc:        directory
```

#### find and locate
- `find dir -name file -print` searches **live** (slow on big trees, but always current).
- Quote patterns: `find /etc -name '*.service'` (otherwise the **shell** expands `*` first).
- Don't use fancy options like `-exec` until the basic form is second nature.
- `locate` searches a **prebuilt index**: very fast, but misses files newer than the index. **Not installed on either of my machines.**
```
$ find /etc -name hostname -print 2>/dev/null
Pi: /etc/apparmor.d/hostname   /etc/hostname
VM: /etc/hostname
$ find /etc -name '*.service' 2>/dev/null | wc -l   → Pi 100, VM 80
```
(`2>/dev/null` throws away "Permission denied" errors into the black hole. Lesson 4.)

#### head and tail
- `head file` = first 10 lines · `tail file` = last 10 lines · `head -5` / `tail -5` = 5 lines
- `tail -n +48 file` = from line 48 to the end (the book writes `tail +n`; modern tail wants `-n +n`)
- `tail -f logfile` = **follow** a log live as new lines arrive (`Ctrl-c` to stop). Used constantly at work.

#### sort
- Alphanumeric order by default. `-n` = numeric order, `-r` = reverse.
- Classic combo: `sort | uniq -c | sort -rn` = count duplicates, biggest first (used above for attackers).

### Interview answers
- **Absolute vs relative path?** "Absolute starts at `/` and works from anywhere; relative is from the current directory and can use `.` and `..`."
- **Why is `cd` a built-in?** "A separate program would run as a child process and could only change its own directory, not the shell's."
- **Who expands `*`?** "The shell, before the command runs. The command only sees the list of filenames, which is why you quote patterns for `find` and `grep`."
- **How do you find failed SSH logins?** `grep -E 'Failed password|Invalid user' /var/log/auth.log` (or `journalctl -u ssh`), then count by user/IP with `sort | uniq -c | sort -rn`.
- **How do you watch a log live?** `tail -f /var/log/syslog`.

### grep नेपालीमा (grep explained in Nepali)
**grep = फाइलभित्र शब्द खोज्ने command।** Browser मा **Ctrl + F** जस्तै। grep ले हरेक line पढ्छ र खोजेको शब्द भएका line मात्र देखाउँछ। 🌾 **छलनी (sieve)** जस्तै: मिलेका line मात्र तल झर्छन्।

```
grep   [option]   शब्द      फाइल
grep              root      /etc/passwd     → /etc/passwd मा "root" भएका line
```
⚠️ grep ले शब्द जहाँ भए पनि भेट्छ (`chroot` भित्रको `root` पनि)।

| Option | के गर्छ | सम्झने तरिका |
|---|---|---|
| `-v` | शब्द **नभएका** line (उल्टो) | re**v**erse |
| `-c` | **गन्ती** मात्र | **c**ount |
| `-i` | ठूलो/सानो अक्षर फरक नपर्ने | **i**gnore case |
| `-w` | **पूरा शब्द** मात्र | **w**ord |

```
grep -c nologin /etc/passwd      → 42  (login गर्न नमिल्ने system users)
grep -vc nologin /etc/passwd     → 8   (login गर्न मिल्ने: root, rabindrakunwar ...)
42 + 8 = 50 = जम्मा users (getent passwd | wc -l)
```

काममा: `grep -i error /var/log/syslog` (error खोज्न) · `grep -c "Invalid user" /var/log/auth.log` (hack प्रयास गन्न) · `ps -ef | grep ssh` (अर्को command को output भित्र खोज्न)

> **एक लाइनमा:** grep = फाइल वा output भित्र शब्द खोजेर, त्यो शब्द भएका line मात्र देखाउने command। `-v` उल्टो, `-c` गन्ती, `-i` ठूलो-सानो अक्षर बिर्सन्छ।

### Lesson 2 quiz: what I got wrong at first
- **Who expands `*.txt`?** I said `ls`. Wrong: the **shell** expands it **before** running the command; `ls` only receives the filenames. That's why patterns for `find`/`grep` go in quotes.
- **Lines without a word:** `grep -v word file`. My first retry `grep -v error /etc.passwd` had two mistakes: the wrong word, and `/etc.passwd` (dot) instead of `/etc/passwd` (slash). Every character counts; use Tab completion.
- `cd..` (no space) → `bash: cd..: command not found`. Must be **`cd ..`**: command, space, argument.

### My grep practice output, explained (नेपालीमा)
**1. `grep -i BASH /etc/passwd`**
```
root:x:0:0:root:/root:/bin/bash
rabindrakunwar:x:1000:1000:Rabindra Kunwar:/home/rabindrakunwar:/bin/bash
```
- `BASH` (ठूलो) खोज्दा `bash` (सानो) भेटियो, `-i` ले गर्दा। `-i` बिना केही आउँदैनथ्यो।
- `/etc/passwd` को ७ भाग: `username : x : UID : GID : पूरा नाम : home folder : shell`
- यसको अर्थ: bash shell भएका (login गर्न मिल्ने) user दुई जना: `root` र म।
- रातो रङ: `grep is aliased to 'grep --color=auto'` (`type grep`)

**2. `ps -ef | grep tmux`**: `|` (pipe) ले `ps` को output `grep` लाई दिन्छ।
```
UID       PID     PPID  STIME  TTY    CMD
rabindr+  35840      1  Nov07  ?      tmux new-session -d -s linux -n main   ← tmux SERVER
rabindr+  868829 868827 22:39  pts/1  tmux attach-session -t linux          ← tmux CLIENT
rabindr+  881496  35841 23:44  pts/2  grep --color=auto tmux                ← grep आफैं!
```
- **Server** (PPID 1 = systemd, TTY `?` = कुनै terminal छैन): Nov 7 देखि चलिरहेको। Connection टुटे पनि session यसैले जोगाउँछ। 📺 TV station।
- **Client** (parent = `bash ./dual-terminal.sh`): मैले हेरिरहेको झ्याल। 📺 TV। बन्द गरे पनि station चलिरहन्छ; `attach` ले फेरि जोड्छ।
- **grep आफैं**: grep को command मा पनि "tmux" छ, त्यसैले आफैंलाई भेट्यो 🪞। Parent 35841 = Pi pane को bash।

Process family (fork, Chapter 1):
```
systemd (1) └─ tmux server (35840) └─ bash, Pi pane (35841) └─ grep tmux (881496)
```
grep ले आफैंलाई नभेटोस्: `pgrep -a tmux` वा `ps -ef | grep [t]mux` (`[t]mux` pattern ले "tmux" मिलाउँछ, तर grep को आफ्नै command line मा "[t]mux" छ, "tmux" छैन)। Interview trick!

### Q: What is a GID? (2026-11-10)
**GID = Group ID**, the number of a group. Like UIDs, the kernel uses numbers, not names.

```
rabindrakunwar:x:1000:1000:Rabindra Kunwar:/home/rabindrakunwar:/bin/bash
                     UID  GID ← primary group (4th field of /etc/passwd)
```
UID 1000 and GID 1000 are different things with the same number: Ubuntu creates a **private group with the same name** for each user.

```
$ id      (Pi)
uid=1000(rabindrakunwar) gid=1000(rabindrakunwar) groups=1000(rabindrakunwar),4(adm),24(cdrom),27(sudo),...
```
| | Meaning | Mine |
|---|---|---|
| **Primary group** (`gid=`) | new files I create get this group | `rabindrakunwar` (1000) |
| **Supplementary groups** (`groups=`) | extra access through membership | `adm` (4), `sudo` (27), ... |

Groups are defined in **`/etc/group`** (`name:x:GID:members`):
```
sudo:x:27:rabindrakunwar          (Pi)
sudo:x:27:ubuntu,adminrabin       (VM: two accounts can become root)
adm:x:4:syslog,rabindrakunwar
```

**Why I can read the login log without sudo:**
```
-rw-r----- 1 syslog adm 381667 Nov 10 23:30 /var/log/auth.log
```
Group = `adm`, the group may read (`r--`), and I'm in `adm` → allowed. Others get "Permission denied".

**GIDs are per machine:** `netdata` is GID 972 on the Pi but 997 on the VM. This matters when copying files between servers (Chapter 12).

🇳🇵 GID = group को नम्बर। नयाँ फाइल primary group (1000) को हुन्छ; `adm`, `sudo` जस्ता group मा भएकाले थप अधिकार पाइन्छ।

**Interview:** "A GID is a group's numeric ID. Each user has a primary group (in /etc/passwd) that new files inherit, plus supplementary groups (in /etc/group). Files have separate group permissions, so group membership is how access is shared, e.g. `adm` for logs, `sudo` for admin."

---

## Lesson 3: Shell environment, editors, help (2.6–2.13, PDF p.48–54)

### 2.6 Changing your password and shell
- `passwd` changes your password (old one once, new one twice).
- Best passwords are **long nonsense sentences**, 16+ characters. Length beats strange symbols.
- `chsh` changes your login shell (zsh, ksh, tcsh). The book assumes bash.

### 2.7 Dot files
- Files/dirs starting with `.` are **hidden**: `ls` skips them, `ls -a` shows them. Examples: `.bashrc`, `.profile`, `.ssh`.
- Nothing special about them: they're hidden just to keep `ls` tidy. Mostly **configuration**.
- Globs like `*` don't match dot files. Use `.*` explicitly.
```
            ls     ls -a
Pi home:    20     38       ← 18 hidden entries
VM home:    11     24
```
⚠️ **Book vs reality:** the book warns that `.*` also matches `.` and `..` (dangerous with `rm -r .*`). **bash 5.2+ has `globskipdots` on by default**, so `.*` no longer matches `.`/`..`. Both machines: Pi bash 5.3.9, VM bash 5.2.21, `globskipdots on`. Still never run `rm -r .*`: older systems behave the book's way.

### 2.8 Shell variables vs environment variables
- **Shell variable:** `STUFF=blah` (⚠️ **no spaces around `=`**). Read it with `$STUFF`. It lives only in this shell.
- **Environment variable:** a shell variable made **exportable**: `export STUFF`. Passed to **every program the shell starts** (child processes inherit the environment: fork + exec).
- Programs read env vars for configuration (e.g. `LESS` for less's options; man pages have an ENVIRONMENT section).
- `PS1` is a shell variable that controls the prompt.

**Real test, same result on both machines:**
```
$ STUFF=blah
$ echo "[$STUFF]"                  → [blah]    the shell sees it
$ bash -c 'echo "[$STUFF]"'        → []        a child process does NOT
$ export STUFF
$ bash -c 'echo "[$STUFF]"'        → [blah]    after export, the child inherits it
```
```
$ env | wc -l                      → Pi 60, VM 18   (number of environment variables)
HOME=/home/rabindrakunwar · USER=rabindrakunwar · SHELL=/bin/bash · LANG=en_US.UTF-8   (Pi)
HOME=/home/ubuntu · USER=ubuntu · SHELL=/bin/bash · LANG=C.UTF-8                     (VM)
```
**The prompt decoded:** `PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '`
→ `\u` user · `@` · `\h` host · `:` · `\w` working dir · `\$` = `$` (or `#` when root). So `rabindrakunwar@rabindrakunwar:~$`.

### 2.9 The command PATH
- `PATH` = env var listing the directories the shell searches for commands, **separated by `:`**, searched **left to right**. The **first match wins**.
```
$ echo $PATH | tr ':' '\n'         ← identical on both machines
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/sbin
/bin
/usr/games
/usr/local/games
/snap/bin
$ type -a ls
ls is /usr/bin/ls                  ← found first, this one runs
ls is /bin/ls                      ← same file (/bin → /usr/bin symlink)
```
- Add a dir **first**: `PATH=dir:$PATH` · **last**: `PATH=$PATH:dir`
- Mistyped `$PATH` and broke it? Just open a new terminal. It's only temporary until saved in a config file.
- 🔐 Security: never put `.` (current dir) early in PATH. A malicious `ls` in a folder could run instead of the real one.

### 2.10 Special characters (Table 2-1)
| Char | Name | Uses |
|---|---|---|
| `*` | star, asterisk | regex, glob |
| `.` | dot | current dir, file/hostname separator |
| `!` | bang | negation, command history |
| `\|` | pipe | command pipes |
| `/` | (forward) slash | directory separator, search |
| `\` | backslash | literals, macros (never directories) |
| `$` | dollar | variables, end of line |
| `'` | tick, single quote | literal strings |
| `` ` `` | backtick | command substitution |
| `"` | double quote | semi-literal strings |
| `^` | caret | negation, beginning of line |
| `~` | tilde, squiggle | negation, home dir shortcut |
| `#` | hash, sharp, pound | comments, substitutions |
| `[ ]` | (square) brackets | ranges |
| `{ }` | braces, curly brackets | statement blocks, ranges |
| `_` | underscore | substitute for a space |

Control keys are written with a caret: `^C` = Ctrl-C.

### 2.11 Command-line editing (Table 2-2)
| Keys | Action |
|---|---|
| `Ctrl-B` / `Ctrl-F` | cursor left / right |
| `Ctrl-P` / `Ctrl-N` | previous / next command (history) |
| `Ctrl-A` / `Ctrl-E` | start / end of line |
| `Ctrl-W` | erase previous word |
| `Ctrl-U` | erase cursor → start of line |
| `Ctrl-K` | erase cursor → end of line |
| `Ctrl-Y` | paste what was erased |

These same keys work in many Unix programs, so learn them instead of the arrow keys. Plus **Tab** = autocomplete (already using it), `Ctrl-R` = search history (bonus).

### 2.12 Text editors
- Most config is plain text (`/etc`), so you **must** be able to edit files without damaging them.
- The two standards: **vi** (fast, "plays like a video game") and **Emacs** (does everything, lots of help).
- The book warns against getting stuck on beginner editors like **nano**. vi exists on almost every server, so learn it.
- Terminal editors (vi) use the terminal's I/O; GUI editors open their own window.

| Editor | Pi | VM |
|---|---|---|
| `vi` | ✅ (VIM 9.1) | ✅ |
| `vim` | – | ✅ |
| `nano` | ✅ | ✅ |
| `emacs` | – | – |

**vi survival kit:**
| Do | Keys |
|---|---|
| open | `vi file` |
| start typing (Insert mode) | `i` |
| stop typing (back to Normal mode) | `Esc` |
| save + quit | `:wq` + Enter |
| quit **without** saving | `:q!` + Enter |
| delete line / undo | `dd` / `u` |
| search | `/word`, then `n` |

vi has **modes**: Normal (keys are commands) and Insert (keys type text). Lost? Press `Esc`.

### 2.13 Getting online help
- `man ls` = the manual page. Reference, not a tutorial. Navigate like `less` (`/search`, `q`).
- `man -k keyword` = search for pages by keyword (when you don't know the command name).
- **Manual sections:**

| Section | Contents |
|---|---|
| 1 | user commands |
| 2 | kernel system calls |
| 3 | programming library |
| 4 | devices / drivers |
| 5 | **file formats** (config files) |
| 6 | games |
| 7 | conventions, encodings |
| 8 | **system/admin commands** and servers |

- Written like `ping(8)`. Same name in several sections → `man 5 passwd` (the **file** `/etc/passwd`) vs `man passwd` (the **command**, section 1).
- Also: `command --help` / `-h`, `info command`, and `/usr/share/doc/` (Pi: 2,349 entries, VM: 1,560).
```
$ man -w ls        Pi: /usr/share/man/man1/rust-ls.1.gz   ← the Rust ls again
                   VM: /usr/share/man/man1/ls.1.gz
$ man -k '^sort$'  sort (1) - sort lines of text files
$ man -w 5 passwd  /usr/share/man/man5/passwd.5.gz
```

### Interview answers
- **Shell vs environment variable?** "A shell variable exists only in the current shell; `export` makes it an environment variable, which child processes inherit."
- **How does the shell find `ls`?** "It searches the directories in `$PATH` left to right and runs the first match. `type -a` or `which` shows where."
- **A script works for you but cron says 'command not found'. Why?** "cron runs with a minimal PATH. Use full paths or set PATH in the job." (Chapter 7)
- **How do you exit vi?** `Esc` then `:wq` to save, `:q!` to discard.
- **Where's the documentation for /etc/passwd's format?** `man 5 passwd`.

### Lesson 3 quiz: first attempt (retry Q2, Q3, Q5 tomorrow)
- ✅ Q4: quit vi without saving = `Esc` `:q!` Enter
- ⚠️ Q1: hidden files start with `.`, shown with **`ls -a`**. They're usually **settings files**, hidden only to keep `ls` tidy (not because they're "system files").
- 🔁 Q2: shell variable = private to this shell; **`export`** makes it an environment variable, which **child processes inherit**. (Shell var = आफ्नो मात्र; export पछि बच्चा process लाई पनि पुग्छ।)
- 🔁 Q3: the shell searches the folders in **`$PATH`, left to right**, and runs the **first match**. (PATH का folder बायाँबाट दायाँ खोज्छ।)
- 🔁 Q5: `man passwd` = the passwd **command** (section 1); **`man 5 passwd`** = the **`/etc/passwd` file** format (section 5).
- vi lab: wrote `~/lab/ch02/vi-test.txt` ✅. Pressing `Ctrl-C` in vi doesn't quit: Vim shows a hint (`Type :qa! ...`). Use `Esc` then a `:` command.

### Q: why did my two terminals disappear? (2026-11-11)
- `exit` in the VM pane (00:12) closed that pane; `exit` in the Pi pane (08:48) closed the last one.
- **When the last pane closes, the tmux session ends.** The Pi itself was fine (up 3 days).
- Evidence: `tmux ls` → `no server running`; journal: `tmux-spawn-....scope: Consumed ... over 3d 8h 58min`; last line of `~/.bash_history` = `exit`.
- Fix: `~/linux-project/dual-terminal.sh` starts a fresh session.

| To... | Do | Session afterwards |
|---|---|---|
| step away, keep everything | `Ctrl-b` then `d` (detach) | ✅ keeps running |
| leave the VM only | `exit` in the VM pane → drops to a Pi shell (`ssh vm` to return) | ✅ |
| close a pane for good | `exit` in its Pi shell | pane gone |
| close everything | `exit` in every pane, or `./dual-terminal.sh stop` | ❌ ended |

---

## Lesson 4: Shell input/output and error messages (2.14–2.15, PDF p.54–58)

### 2.14 Redirection: sending output somewhere other than the screen
| Syntax | Does |
|---|---|
| `cmd > file` | stdout → file. **Creates** it, or **erases (clobbers)** it first if it exists ⚠️ |
| `cmd >> file` | stdout → **appends** to the end of file |
| `cmd1 \| cmd2` | **pipe**: stdout of cmd1 → stdin of cmd2. Chain as many as you like |
| `cmd 2> file` | **stderr** (stream 2) → file |
| `cmd > f 2>&1` | stdout → f, then stderr → **wherever stdout goes** (also f) |
| `cmd < file` | file → stdin of cmd (rarely needed: most commands take a filename) |
| `set -C` | bash "noclobber": `>` refuses to overwrite existing files |

**Real, both machines:**
```
$ echo "BTC 97000" > prices.txt
$ echo "ETH 3400"  > prices.txt     ← > ERASED the BTC line!
$ cat prices.txt
ETH 3400
$ echo "BTC 97000" >> prices.txt    ← >> appends
$ cat prices.txt
ETH 3400
BTC 97000

$ set -C; echo x > prices.txt
bash: prices.txt: cannot overwrite existing file      ← noclobber protects it
```

**Pipe, the same command on two CPUs:**
```
$ head -3 /proc/cpuinfo | tr a-z A-Z       (tr a-z A-Z = lowercase → UPPERCASE)
Pi:  PROCESSOR : 0 · BOGOMIPS : 108.00 · FEATURES : FP ASIMD ...      ← ARM
VM:  PROCESSOR : 0 · VENDOR_ID : AUTHENTICAMD · CPU FAMILY : 23     ← AMD EPYC (x86)
```

#### 2.14.1 Standard error
- **stderr** = a separate output stream (ID **2**) for errors/diagnostics, so errors still reach the screen even when stdout is redirected.
- Stream IDs: **0 = stdin, 1 = stdout (the default for `>`), 2 = stderr**.
```
$ ls /fffffffff > f
ls: cannot access '/fffffffff': No such file or directory   ← still on screen (stderr)
f has 0 bytes                                               ← nothing went to stdout

$ ls /fffffffff > f 2> e         → error saved in e
$ ls /fffffffff /etc/hostname > f 2>&1
$ cat f                          → BOTH the error AND "/etc/hostname"
```
- ⭐ **`2>/dev/null`** = send errors into the black hole (Chapter 1 pseudodevice). Used earlier: `find /etc -name '*.service' 2>/dev/null` hid the "Permission denied" noise.
- ⚠️ Order matters: `> f 2>&1` (both to f) ✅ vs `2>&1 > f` (stderr still on screen). Read `2>&1` as "stderr → wherever stdout points **right now**".

#### 2.14.2 Standard input redirection
```
$ head -2 < /proc/cpuinfo        same as: head -2 /proc/cpuinfo
```

### 2.15 Understanding error messages
**Always read the error message.** Unix errors usually say exactly what went wrong.

#### 2.15.1 Anatomy
```
ls: cannot access '/dsafsda': No such file or directory
│                  │          └ the problem
│                  └ the file/path involved
└ the program that complained
```
- "ls tried to open /dsafsda but couldn't because it doesn't exist."
- ⭐ **Fix the FIRST error first.** Later errors are often consequences of the first (e.g. a missing config file, then 50 other complaints).
- **Warning ≠ error:** warnings contain the word *warning*; the program tries to keep going.

#### 2.15.2 Common errors (most come straight from kernel system calls)
| Error | Meaning | Real trigger (both machines) |
|---|---|---|
| **No such file or directory** (`ENOENT`) | the #1 error: the path doesn't exist | `cat /nope` |
| **File exists** | creating something that's already there | `mkdir a` when file `a` exists |
| **Not a directory** / **Is a directory** | using a file as a dir, or a dir as a file | `touch a/b` when `a` is a file; `rm reports` |
| **No space left on device** | disk full | (Pi: 12G free of 28G, VM: 36G of 49G) |
| **Permission denied** | not allowed to read/write, or no execute bit | `cat /etc/shadow`; `./s.sh` without `chmod +x` |
| **Operation not permitted** | usually killing a process you don't own | `kill 1` (PID 1 = systemd, owned by root) |
| **Segmentation fault** / **Bus error** | program touched memory it wasn't allowed to (a program bug, bad input, rarely bad RAM). The kernel kills it | exit code **139** = 128 + signal 11 (SIGSEGV) |

**The kernel's error code, seen with strace (VM):**
```
openat(AT_FDCWD, "/nope", O_RDONLY) = -1 ENOENT (No such file or directory)
cat: /nope: No such file or directory
```
The system call returned `-1 ENOENT`, and `cat` turned it into the human message. (`man 2 open` lists every error `open()` can return.)

**Same error, different wording on each machine** (the book says programs differ subtly):
```
Pi (Rust coreutils):  touch: setting times of 'a/b': Not a directory
VM (GNU coreutils):   touch: cannot touch 'a/b': Not a directory
Pi:  mkdir: a: File exists
VM:  mkdir: cannot create directory 'a': File exists
```
The **last part** (the actual problem) is the same. Read the end of the message.

**Segfault ↔ Chapter 1:** a segmentation fault is the **MMU + kernel** catching a process touching memory outside its page table → the kernel kills it.

### Interview answers
- **`>` vs `>>`?** "`>` overwrites (creates or truncates), `>>` appends."
- **What does `2>&1` mean?** "Redirect stderr (2) to the same place as stdout (1). `cmd > log 2>&1` captures both in one file."
- **What is `2>/dev/null`?** "Discard error messages."
- **A service won't start and prints 40 errors. What do you do?** "Read the first error first; the rest are often consequences."
- **Permission denied vs Operation not permitted?** "Permission denied = file access/execute rights; Operation not permitted = an action you lack privilege for, e.g. killing another user's process."
- **What is a segfault?** "The process accessed memory it isn't allowed to; the MMU traps it and the kernel kills it with SIGSEGV (exit 139)."

### Q: where is /etc/passwd? (2026-11-11)
`/etc/passwd` = the **file** `passwd`, inside the **folder** `etc`, at the **root** `/` of the disk (absolute path).
```
/
├── etc/          ← system configuration files (240 items on Pi, 211 on VM)
│   ├── passwd    ← list of users (one line each: 50 Pi, 43 VM)
│   └── group     ← list of groups
└── home/rabindrakunwar/   ← ~
```
```
$ ls -l /etc/passwd
Pi: -rw-r--r-- 1 root root 2924 Aug 16 22:28 /etc/passwd    ← owned by root, readable by everyone
VM: -rw-r--r-- 1 root root 2366 Sep  8 12:42 /etc/passwd
$ file /etc/passwd → ASCII text
```
- Don't edit it by hand. Use commands like `useradd`/`usermod` (Chapter 7).
- Real password hashes live in **`/etc/shadow`** (root-only), hence `cat /etc/shadow` → Permission denied.

### Lesson 3 retry + Lesson 4 quiz ✅
- Retries passed: child sees **environment** vars (made with `export`); shell searches **`$PATH` left to right**, first match wins; **`man 5 passwd`** = the file format.
- Q4 in full: `ls /nope > out.txt` still prints the error because `>` only redirects **stdout (1)**; the error goes to **stderr (2)**, which still points at the screen.
- Q6 fix: **Permission denied** = not allowed to **read, write, OR execute** (run) a file. Not just "make changes": `cat /etc/shadow` (read) and `./s.sh` without `+x` (execute) both gave it.

### /dev/null explained again (2026-11-11)
**`/dev/null` = a fake file (kernel pseudodevice) that swallows everything written to it and always reads as empty.** 🗑️ A bin that empties itself instantly.
```
$ echo "hello" > /dev/null     → nothing printed
$ cat /dev/null | wc -c        → 0
$ ls -l /dev/null              → crw-rw-rw- 1 root root 1, 3 ... (c = character device; everyone can write)
```
**Why use it: to hide noise.** Real, Pi:
```
$ find / -name passwd | wc -l              → 1,947 lines (mostly "Permission denied" errors)
$ find / -name passwd 2>/dev/null          → only the 18 real results (/etc/passwd, /usr/bin/passwd, ...)
```
`2>/dev/null` = stream 2 (stderr) → the black hole. Normal output still shows.

| Command | Hides |
|---|---|
| `cmd 2>/dev/null` | errors only |
| `cmd >/dev/null` | normal output only |
| `cmd >/dev/null 2>&1` | everything (common in scripts/cron) |

⚠️ Don't hide errors while troubleshooting; they're clues. Only discard errors you know don't matter.

---

## Lesson 5: Listing and manipulating processes (2.16, PDF p.58–61)

### Learn

A **process** is a running program (Ch1). Every process has a **PID**, a unique number. When a process ends, the kernel can reuse its PID later.

#### `ps`: list processes

The default columns are **PID, TTY, TIME, CMD**:

| Column | Meaning |
|---|---|
| PID | process ID |
| TTY | terminal it's attached to (`pts/0` = an SSH/tmux terminal, `?` = no terminal, e.g. a daemon) |
| STAT | state: **S** sleeping, **R** running, **T** stopped, **I** idle kernel thread, **D** uninterruptible sleep (usually waiting on disk), **Z** zombie |
| TIME | **CPU time** used, not how long it has been alive (wall-clock time) |
| COMMAND | the command line, which a process can change itself |

STAT extra letters: `s` session leader, `l` multi-threaded, `<` high priority, `+` in the foreground of its terminal.

**BSD-style options** (no dash), which the book uses:

| Command | Shows |
|---|---|
| `ps x` | all **my** processes |
| `ps ax` | **all** processes on the system |
| `ps u` | add user, %CPU, %MEM, VSZ, RSS, START |
| `ps w` | wide: full command lines |
| `ps aux` / `ps auxw` | combined; the one everyone types |
| `ps u $$` | just my current shell (`$$` = the shell's own PID) |

Columns from `u`: **VSZ** is virtual memory size in KB; **RSS** is the real RAM in use in KB (resident set size).

#### Signals and `kill`

A **signal** is a message **from the kernel** to a process. `kill` asks the kernel to send one. Despite the name, `kill` doesn't always kill.

| Signal | No. | Sent by | Effect | Can it be ignored? |
|---|---|---|---|---|
| TERM | 15 | `kill pid` (the default) | "please exit": the process can clean up | yes |
| INT | 2 | **Ctrl-C** | interrupt | yes |
| KILL | 9 | `kill -9` / `kill -KILL` | kernel removes it immediately, no cleanup | **no** |
| STOP | 19 | `kill -STOP` | freeze (still in memory) | **no** |
| TSTP | 20 | **Ctrl-Z** | polite stop from the terminal | yes |
| CONT | 18 | `kill -CONT`, `fg`, `bg` | continue after a stop | n/a |
| HUP | 1 | terminal closed / `kill -HUP` | hang-up; many daemons use it to mean "reload config" | yes |

`kill -l` lists every signal with its number.

**Order to try:** `kill pid` (TERM) → wait a few seconds → only then `kill -9 pid`. KILL gives no chance to flush files, remove lock files or close connections. For a trading feed handler, that can mean a half-written file or a stale lock.

**Exit status after a signal = 128 + signal number**, so you can tell *how* something died:
- TERM: 128 + 15 = **143**
- KILL: 128 + 9 = **137** (also what you see when the OOM killer strikes)
- INT: 128 + 2 = **130**
- SEGV: 128 + 11 = **139** (from Lesson 4)

#### Job control

Job control is the shell's way of sending TSTP/CONT with keys:

| Key/command | Does |
|---|---|
| `Ctrl-Z` | suspend the foreground job (TSTP) |
| `jobs` | list this shell's jobs (`[1]+ Stopped ...`) |
| `fg` / `fg %1` | bring job 1 back to the foreground |
| `bg` / `bg %1` | let a stopped job continue in the background |
| `kill %1` | signal job 1 by job number instead of PID |

⚠️ The common beginner trap is pressing **Ctrl-Z instead of Ctrl-C**. The program isn't gone, only stopped. Run `jobs` to check.

#### Background processes: `&`

`command &` starts the command in the background, prints `[job] PID` and gives the prompt back at once.

Problems with background jobs:
- If it reads stdin, it freezes; use `fg` to bring it back.
- If it writes output, the text lands in the middle of your screen. Redirect it: `cmd > out.log 2>&1 &`.
- **Ctrl-L** redraws a messy screen. **Ctrl-R** at the bash prompt is reverse search; press Esc to leave.
- Over SSH, a job can die when you log out (HUP). `nohup cmd &` or **tmux** keeps it alive. That's why we use tmux.

### Lab: real output

#### `ps` with no options: Pi vs VM

Run from Claude's shell, which has **no terminal**, so TTY is `?` everywhere. In your tmux pane you'll see `pts/N` instead.

Pi:
```
    PID TTY          TIME CMD
   1945 ?        00:01:15 python3          <- tv-webhook on the Pi (localhost:8800)
  22093 ?        00:00:01 systemd          <- my per-user systemd
 963816 ?        00:00:01 tmux: server     <- the dual-terminal tmux session
1092736 ?        00:00:00 bash
1092737 ?        00:00:00 ps               <- ps sees itself
```
VM:
```
    PID TTY          TIME CMD
    968 ?        00:12:31 python3          <- 12.5 min of CPU since Nov 8
 338731 ?        00:00:00 systemd
 424495 ?        00:00:00 bash
 424496 ?        00:00:00 ps
```
Notice that the Pi's PIDs are above **1 million** while the VM's are ~424k. PIDs only grow until they wrap around, so a big PID means many processes have been started since boot.

#### `ps aux`: the top of the list (Pi)
```
USER   PID %CPU %MEM   VSZ   RSS TTY STAT START  TIME COMMAND
root     1  0.0  0.4 27884 18280 ?   Ss   Nov07  3:18 /usr/lib/systemd/systemd ...
root     2  0.0  0.0     0     0 ?   S    Nov07  0:56 [kthreadd]
root     4  0.0  0.0     0     0 ?   I<   Nov07  0:00 [kworker/R-rcu_gp]
```
- **PID 1 = systemd**, the first user-space process (Ch6).
- **PID 2 = kthreadd**, the parent of all kernel threads. Names in **[brackets]** are kernel threads (Ch1), with VSZ/RSS of 0 because they have no user-space memory.

#### Count processes by state
```bash
ps aux | wc -l                                    # Pi: 200 lines   VM: 141 lines (minus 1 header)
ps ax -o stat= | cut -c1 | sort | uniq -c | sort -rn
```
| State | Pi | VM |
|---|---|---|
| S sleeping | 128 | 86 |
| I idle kernel threads | 73 | 56 |
| R running | 1 | 1 |

Almost everything is **sleeping** (waiting for input, a timer or the network). The only R is `ps` itself. A healthy box looks like this. Lots of **D** would point to a disk problem; lots of **Z** to a buggy parent process.

#### Who eats the VM's RAM? (`ps aux --sort=-%mem`)
```
USER     PID   %CPU %MEM    VSZ    RSS  COMMAND
netdata  392831 1.8 10.6 743560 104180 /usr/sbin/netdata ...
root     364    0.0  8.9 177508  87264 /usr/lib/systemd/systemd-journald
netdata  393447 0.2  8.4 1535012 82588 .../go.d.plugin 1
```
On a 954 MB VM, **netdata uses ~19% of RAM** (10.6 + 8.4). That's worth remembering for the monitoring pillar of trading-infra-lab. Note VSZ (1.5 GB) ≫ RSS (82 MB): virtual memory is mostly reserved, not used (Ch1, virtual memory).

#### Signals demo: STOP → CONT → TERM (same result on Pi and VM)
```bash
sleep 300 &  P=$!          # $! = PID of the last background job
ps -o pid,stat,cmd -p $P   # S  = sleeping
kill -STOP $P              # T  = stopped (frozen)
kill -CONT $P              # S  = back to normal
kill $P; wait $P; echo $?  # TERM
```
Real Pi output:
```
1092752 S    sleep 300
1092752 T    sleep 300      <- after STOP
1092752 S    sleep 300      <- after CONT
exit status after TERM: 143
/bin/bash: line 7: 1092760 Killed      sleep 300
exit status after KILL: 137
exit status after INT: 130
```
The shell even prints **"Killed"** for signal 9. That's the same message you'd see if the OOM killer took a process.

#### `kill -l` (identical on both, same Linux kernel)
```
 1) SIGHUP   2) SIGINT   3) SIGQUIT  ...  9) SIGKILL ... 15) SIGTERM
17) SIGCHLD 18) SIGCONT 19) SIGSTOP 20) SIGTSTP ...
```

### Interview angle
- **"Difference between `kill` and `kill -9`?"** TERM (15) asks the process to exit and lets it clean up. KILL (9) is handled by the kernel, can't be caught, and allows no cleanup. Always try TERM first.
- **"A process won't die even with `kill -9`?"** It's probably in **D state** (stuck in the kernel waiting on I/O, e.g. a dead NFS mount or disk), or it's a **zombie** (already dead; its parent must `wait()` for it, so fix or kill the parent).
- **"A service exited with code 137. What happened?"** 128 + 9 means SIGKILL, very often the **OOM killer**. Check `dmesg` / `journalctl -k`.
- **"How do you keep a job running after you log out?"** `tmux`/`screen`, `nohup`, or better, make it a **systemd service** (Ch6).
- **"How do you make a daemon reload its config without a restart?"** Many daemons (nginx, sshd) reload on **HUP**: `kill -HUP pid`, or `systemctl reload`.
- **"Find the top memory users"**: `ps aux --sort=-%mem | head`.

### Q1 explained again: "I ran `kill` and the process is still alive" (2026-11-11)

**Analogy: closing time at a shop**
- `kill pid` (TERM, 15) = the manager says *"We're closing, please finish up and leave."* A polite customer packs their bag and leaves. A rude one ignores it.
- `kill -9 pid` (KILL, 9) = **security carries them out**. No asking, no packing up, and it can't be refused. But whatever they were holding gets dropped on the floor.

**So the answer to Q1:**
1. `kill 4321` sent TERM, and the process ignored it or got stuck while cleaning up.
2. Wait a few seconds, check again with `ps -p 4321`.
3. Still there? Use `kill -9 4321`.
4. **Why not `-9` first?** KILL gives the program **no chance to clean up**: unsaved data is lost, temp/lock files are left behind, network connections are cut. Always ask nicely first.

**Real demo on the Pi: a "stubborn" process that ignores TERM**
```bash
bash -c 'trap "echo I got TERM but I am ignoring it" TERM; while true; do sleep 1; done' &
P=$!
kill $P            # polite
ps -o pid,stat,cmd -p $P
kill -9 $P         # forced
ps -o pid,stat,cmd -p $P
```
`trap ... TERM` tells bash: "when TERM arrives, run this echo instead of exiting."
```
  [stubborn] I got TERM but I am ignoring it
--- after kill (TERM):
    PID STAT CMD
1094992 S    bash -c trap ...     <- still alive!
--- after kill -9 (exit 137):
    PID STAT CMD
  (gone)                          <- KILL can't be trapped
```
Exit status 137 = 128 + 9, which proves it was KILL.

### Q2–Q5 explained simply (2026-11-11)

**Q2: A service exits with status 137. What killed it?**
- Rule: if a process is killed by a signal, exit status = **128 + signal number**.
- 137 − 128 = **9**, which is **KILL**.
- Who sends KILL without anyone typing `kill -9`? Usually the kernel's **OOM killer** (Out Of Memory): RAM ran out, so the kernel picked a process and killed it.
- Cheat table: **130** = Ctrl-C (2), **137** = kill -9 (9), **139** = segfault (11), **143** = plain kill (15).

**Q3: Pressed Ctrl-Z in vi by accident. Is vi gone?**
- **No.** Ctrl-Z = **pause** (like the pause button on a video). Ctrl-C = **stop**.
- vi is still in memory, frozen (state **T**).
- `jobs` shows it: `[1]+  Stopped   vi file.txt`
- `fg` brings it back exactly where you left it.

**Q4: VSZ vs RSS in `ps aux`**
- **VSZ** (virtual size) = memory the process has **reserved**, like a restaurant booking a table for 10.
- **RSS** (resident set size) = memory **actually in RAM right now**, like the 3 people really sitting there.
- RSS is the number that matters for "is RAM running out?".
- Real VM example: go.d.plugin had VSZ **1,535,012 KB** (~1.5 GB) but RSS only **82,588 KB** (~82 MB).

**Q5: `$$` and `$!`**
- **`$$`** = the PID of **my current shell** (myself). `echo $$` shows it; `ps u $$` shows details about it.
- **`$!`** = the PID of the **last thing I started in the background** with `&`.
  ```bash
  sleep 300 &     # shell prints [1] 1092752
  echo $!         # 1092752
  kill $!         # kill that sleep
  ```

### My own job-control run on the Pi, explained line by line (2026-11-11)

```
$ echo $$
963817                          (1) PID of MY shell (the bash in the tmux Pi pane)
$ sleep 300 &
[1] 1097035                     (2) [1] = job number, 1097035 = PID
$ echo $!
1097035                         (3) $! = PID of last background job; matches (2)
$ kill $!
[1]+  Terminated   sleep 300    (4) TERM (15) sent; shell reports the job ended
$ sleep 500
^Z                              (5) Ctrl-Z = TSTP → paused, prompt comes back
[1]+  Stopped      sleep 500
$ jobs
[1]+  Stopped      sleep 500    (6) still alive, frozen in memory (state T)
$ fg
sleep 500                       (7) fg prints the command, resumes it in front
^C                              (8) Ctrl-C = INT (2) → stopped for real
$ echo $?
130                             (9) 128 + 2 = 130 → killed by Ctrl-C
```

Notes:
- (1) `963817` is one more than the tmux server PID (963816): tmux started this bash right after itself.
- (2)/(5) Both got job number `[1]` because job 1 had already finished in (4), so the number was free again.
- `+` in `[1]+` = the "current" job, the one `fg`/`bg` use if you give no number.
- (4) "Terminated" is the shell's word for TERM; with `kill -9` it would say "Killed".
- Ctrl-Z = pause (job survives). Ctrl-C = stop (job ends, exit 130).

### Lesson 5 quiz: my answers (2026-11-11)
1. ✅ `kill -9 PID` if `kill` fails. **Missing part:** why not first? Because -9 gives no cleanup (unsaved data, lock files, open connections are lost).
2. ✅ 137 = killed by signal 9 (128 + 9). **Add:** often the **OOM killer** when RAM runs out.
3. ✅ Ctrl-Z pauses; `fg` brings it back.
4. ✅ VSZ = memory reserved/asked for, RSS = memory actually in RAM.
5. ⚠️ `$$` = my shell's PID ✅. But I mixed up two symbols:
   - **`$!`** = PID of the last **background** job (`&`)
   - **`$?`** = **exit status** of the last command (0 = success, 130 = Ctrl-C, ...)
   - Memory trick: **`?`** = "how did it go?" (a question) · **`!`** = "the one I just launched!"

### My VM experiment: "No such process" and "Operation not permitted" (2026-11-11)

Real output from the VM (`ubuntu@bot-vnic`):
```
ubuntu   428107  0.0 0.4 11336 4460 pts/0  R+  12:26  0:00 ps aux    (A)
[1]+  Killed                 sleep 500                                 (B)
$ kill 428107
-bash: kill: (428107) - No such process                                (C)
$ kill 424161
-bash: kill: (424161) - Operation not permitted                        (D)
$ kill n-9 424161
-bash: kill: n-9: arguments must be process or job IDs                 (E)
-bash: kill: (424161) - Operation not permitted
```

- **(A)** The last line of `ps aux` is **ps itself**: `R+` = running, in the foreground (`+`) of my terminal `pts/0`. By the time I read it, ps had already finished.
- **(B)** The shell reports a job change at the next prompt: my earlier `sleep 500` (job 1) died from signal 9, so it says **Killed** (TERM would say "Terminated").
- **(C)** **No such process** (ESRCH): PID 428107 was the `ps aux` from (A). It ended the moment it printed its list. PIDs of finished processes are gone.
- **(D)** **Operation not permitted** (EPERM): PID 424161 belongs to the user **netdata**, not to me (`ubuntu`). A normal user may only signal **their own** processes. This is least privilege (Ch1) working as designed. Only root can signal other users' processes.
- **(E)** Typo: `n-9` instead of `-9`. kill took `n-9` as a PID or job, rejected it, then still tried 424161 and was refused again. Even a correct `kill -9` would fail: the problem is **permission**, not **signal strength**. KILL can't be ignored by the process, but the kernel still checks whether *you* are allowed to send it.

Other things visible in the screenshot:
- `[kworker/...]` in brackets, owner root, VSZ/RSS 0, STAT `I` = idle **kernel threads**.
- netdata STAT `Sl` = sleeping + multi-threaded.

⚠️ Lesson: don't kill processes you don't recognise, especially with `sudo`. 424161 is part of **netdata** (the VM's monitoring). Killing it would blind the monitoring: "shooting yourself in the foot", as the book says.

---

## Lesson 6: File modes and permissions (2.17, PDF p.61–64)

### Learn

`ls -l` shows the **mode** as the first 10 characters:

```
 -  rw-  r--  r--    1  root  root  2924  Aug 16  /etc/passwd
 │  └┬┘  └┬┘  └┬┘       └┬─┘  └┬─┘
type user group other   owner group
```

- **Type:** `-` regular file, `d` directory, `l` symbolic link (more types in 3.1).
- **3 sets**, in this order: **u**ser (the owner), **g**roup, **o**ther (everyone else, also called "world").
- Each set is `r` read, `w` write, `x` execute, or `-` not granted.
- The kernel checks **only one** set: owner? use the user set. Else in the group? use the group set. Else: other.

#### r, w, x mean different things for files and directories

| | File | Directory |
|---|---|---|
| **r** | read the contents | **list** the names inside (`ls`) |
| **w** | change the contents | create, delete, rename files inside |
| **x** | run it as a program | **enter it / use files inside** (`cd`, open `dir/file`) |

A directory needs **r + x** for normal use. The classic mistake: `chmod 644` on a directory removes x, and then nothing inside can be opened.

#### chmod: symbolic form
```bash
chmod g+r file       # add read for group
chmod go+r file      # group and other
chmod go-r file      # remove
chmod u+x script.sh  # make executable for me
chmod a+x            # all = u, g and o
```

#### chmod: numbers (octal), "absolute" mode
r = **4**, w = **2**, x = **1**; add them per set.

| Mode | Meaning | Used for |
|---|---|---|
| **644** | rw- r-- r-- | normal files |
| **600** | rw- --- --- | private files (SSH keys, configs with secrets) |
| **755** | rwx r-x r-x | programs, public directories |
| **700** | rwx --- --- | private directories |
| **711** | rwx --x --x | dir others can pass through but not list |

Example: 7 = 4+2+1 = rwx, 5 = 4+1 = r-x, 6 = 4+2 = rw-.

#### Special bits
- **setuid** (`s` where the user's x is): the program runs **as its owner**, not as you. `/usr/bin/passwd` is setuid root, so normal users can change their own password in `/etc/shadow`.
- **sticky bit** (`t` at the end, e.g. `/tmp` = `drwxrwxrwt`): everyone can create files, but only the owner can delete their own.

#### umask: default permissions for new files
- New files start from 666, new directories from 777; umask **removes** bits.
- `umask 022` → files 644, dirs 755 (others can read).
- `umask 077` → files 600, dirs 700 (private).
- `umask 002` (Ubuntu's default for normal users) → files **664**, dirs **775** (your private group can write).

#### Symbolic links
- `ln -s target linkname`: a name that **points to another path**, like a Windows shortcut.
- Shows as `l` in ls: `link -> target`. Link permissions are always `rwxrwxrwx`; the target's permissions are what count.
- The target doesn't have to exist, which gives a **broken link**: "No such file or directory" even though you can see the name.
- ⚠️ **Order is target first, then link name.** Forgetting `-s` makes a **hard link** (Section 4.6); avoid for now.

### Lab: real output (Pi vs VM)

#### Who am I and what groups am I in?
```
Pi: uid=1000(rabindrakunwar) gid=1000(rabindrakunwar) groups=...,4(adm),27(sudo),...
VM: uid=1001(ubuntu)         gid=1001(ubuntu)         groups=...,4(adm),27(sudo),...,120(lxd)
umask: 0002 on both
```
Both users are in **sudo** (can become root) and **adm** (can read system logs).

#### The famous files
```
-rw-r--r-- 1 root root   2924 /etc/passwd      <- everyone can read (user list)
-rw-r----- 1 root shadow 1330 /etc/shadow      <- password hashes: only root + group shadow
-r--r----- 1 root root   1800 /etc/sudoers     <- read-only even for root (edit with visudo)
-rwsr-xr-x 1 root root 142552 /usr/bin/passwd  <- s = setuid root
drwxrwxrwt 13 root root 12288 /tmp             <- t = sticky bit
$ cat /etc/shadow
cat: /etc/shadow: Permission denied            <- same on both machines
```
**Why passwd needs setuid:** I'm not allowed to write `/etc/shadow`, but I'm allowed to change my own password. The passwd program runs as root to do that one job safely.

Setuid programs in /usr/bin: **Pi 11, VM 10** (chfn, chsh, gpasswd, mount, passwd, pkexec, su, sudo...). Attackers hunt for these, so security audits list them: `find /usr/bin -perm -4000`.

#### SSH files: why 600 and 700
```
drwx------  ~/.ssh                   700: only me
-rw-------  ~/.ssh/authorized_keys   600
-rw-------  ~/.ssh/config            600
-rw-------  ~/.ssh/pi_to_vm          600: PRIVATE key
-rw-r--r--  ~/.ssh/pi_to_vm.pub      644: public key, fine to share
```
SSH **refuses** to use a private key that others can read ("UNPROTECTED PRIVATE KEY FILE!").

#### New files with umask 002 → 664 / 775
```
-rw-rw-r--  f        (666 - 002 = 664)
drwxrwxr-x  d        (777 - 002 = 775)
```
With `umask 077` in a subshell:
```
-rw-------  private  (600)
drwx------  pdir     (700)
```

#### chmod in action
```
start:            -rw-rw-r--  (664)
chmod go-r f   →  -rw--w----  <- group keeps its w! "-r" only removes r
chmod u+x,g+r  →  -rwxrw----
chmod 644 f    →  -rw-r--r--  <- absolute: sets everything at once
stat -c '%a %A %n' f d  →  644 -rw-r--r-- f   /   775 drwxrwxr-x d
```
`stat -c '%a'` shows the number form: handy when you can't do octal in your head yet.

#### Directory r vs x
```
chmod 644 d   →  drw-r--r--
ls d          →  note                         <- r lets me LIST names
cat d/note    →  cat: d/note: Permission denied   <- no x: can't open anything inside
chmod 711 d   →  drwx--x--x
cat d/note    →  secret                       <- x lets me in
```

#### A script without x
```
./s.sh                →  Permission denied
chmod +x s.sh; ./s.sh →  hi from script
```

#### Symlinks on both systems
```
/bin  -> usr/bin        (Pi and VM: /bin is just a link, "usrmerge")
/sbin -> usr/sbin
/lib  -> usr/lib
/bin/sh -> dash         (from Lesson 1: sh is really dash)
readlink -f /bin/sh  →  /usr/bin/dash   (follow every link to the real file)

ln -s note_missing broken;  cat broken  →  No such file or directory   <- broken link
ln -s d/note link;          cat link    →  secret
```

#### 🔍 Finding: home directory permissions differ
```
Pi: drwxr-x---  /home/rabindrakunwar   (750: other users can't look in)
VM: drwxr-xr-x  /home/ubuntu           (755: ANY user on the VM can list and read it)
VM other homes: adminrabin, opc, rabin  drwxr-x--- (750)
```
On the VM, `/home/ubuntu` is world-readable, and the VM has 4 human-style accounts. That's a security-baseline item for trading-infra-lab (fix: `chmod 750 /home/ubuntu`, after review).

### Interview angle
- **"What does 755 mean? 644? 600?"** Know these instantly.
- **"x on a directory?"** Permission to enter it and access files inside; r only lists names.
- **"Why can a normal user change their password if /etc/shadow is root-only?"** passwd is **setuid root**.
- **"What's the sticky bit on /tmp for?"** Everyone can write, but only the owner can delete their own files.
- **"SSH says UNPROTECTED PRIVATE KEY FILE"**: `chmod 600 ~/.ssh/id_*`, `chmod 700 ~/.ssh`.
- **"Never `chmod 777`"**: anyone on the box can change or replace it. Fix ownership/groups instead.
- **"Symlink vs hard link?"** Symlink points to a **name** (can break, can cross filesystems); hard link is another name for the **same data** (Ch4).

#### My own Lesson 6 lab run on the VM (2026-11-13)
```
ubuntu@bot-vnic:~$ cd ~/p<Tab><Tab>
permlab/   portfolio_dashboard/            <- double Tab lists every match
~/permlab$ touch f; mkdir d; ls -l
drwxrwxr-x 2 ubuntu ubuntu 4096 d          <- 775 (umask 002)
-rw-rw-r-- 1 ubuntu ubuntu    0 f          <- 664
$ chmod 600 f  →  -rw-------               <- private
$ chmod 755 f  →  -rwxr-xr-x  f (green)    <- executable; ls colours it green
$ echo 'echo I run!' >s.sh; ./s.sh
-bash: ./s.sh: Permission denied           <- no x bit
$ chmod +x s.sh; ./s.sh
I run!
$ l -l /usr/bin/passwd /etc/shadow
-rw-r----- 1 root shadow  1335 /etc/shadow
-rwsr-xr-x 1 root root   64152 /usr/bin/passwd*   <- red background = setuid; * = executable
$ ln -s /etc/hostname myhost; ls -l myhost; cat myhost
lrwxrwxrwx 1 ubuntu ubuntu 13 myhost -> /etc/hostname
bot-vnic
```
- `l` is an Ubuntu **alias** for `ls -CF` (also `ll` = `ls -alF`, `la` = `ls -A`). The `F` adds markers: `*` executable, `/` directory, `@` symlink. So `l -l` = `ls -CF -l`.
- ls colours: blue = directory, green = executable, cyan/purple = symlink, **red background = setuid**: ls highlights it on purpose because setuid matters for security.
- The symlink's size is **13** because a symlink only stores the path text: `/etc/hostname` is 13 characters.
- `cat myhost` printed `bot-vnic`: reading the link actually read `/etc/hostname`, the machine's name.
- Same results as the Pi, except the binary sizes (passwd: Pi 142,552 bytes on arm64, VM 64,152 bytes on x86_64; different builds).
