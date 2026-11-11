# Real-world trading company scenarios (Chapter 1 + Chapter 2 up to 2.16)

Problems a Linux / infrastructure engineer at a trading firm really meets, solved **only with what I've learned so far**: processes, signals, job control, grep, find, tail, sort/uniq, redirection, /dev/null, environment variables, PATH, error messages, users and root.

Format for each: **Situation → What you see → Investigate → Root cause → Fix → Prevent → Interview line.**
Where marked 🧪, I reproduced it safely on my Pi with fake data (no trading, no real money, no API keys).

> Background: in trading, **time is money**. Markets open at a fixed time (for example 09:30), and a feed or gateway that is down for 30 seconds at the open can mean missed or bad trades. So the jobs are: notice fast, find the cause fast, fix safely, and write it up.

---

## 1. The market-data feed "froze" but the process is still running 🧪

**Situation:** At 09:31 traders shout "prices stopped updating!". The feed handler process exists, so monitoring that only checks "is the process alive?" says everything is fine.

**What you see:** the log has stopped growing.

**Investigate**
```bash
ps -o pid,stat,cmd -C feed_handler     # STAT = T  → stopped!
tail -1 /var/log/feed/feed.log         # last tick timestamp is old
date                                   # compare with now
```

**Real run on my Pi** (a fake feed writing a "TICK" every 0.2 s, then frozen with `kill -STOP`):
```
lines before: 5  after 2s: 5          <- log not growing
23:24:54.946 TICK BTCUSD              <- last tick
23:24:57                              <- current time: 3 s of silence
    PID STAT CMD
1099470 T    ...                      <- T = stopped
after CONT:
23:24:57.814 TICK BTCUSD              <- ticks flowing again
23:24:58.040 TICK BTCUSD
```

**Root cause:** someone ran the feed **in the foreground** of their SSH session and pressed **Ctrl-Z** (meant Ctrl-C, or just a typo). Ctrl-Z = TSTP, so the process is paused, not dead.

**Fix:** `kill -CONT <pid>` (or `fg` from the same shell).

**Prevent:**
- Never run production processes in someone's terminal. Use **systemd services** (Ch6), or at least tmux.
- Monitor **"is data fresh?"** (age of last tick), not just "is the PID alive?".

**Interview line:** "Process alive ≠ service healthy. I check STAT in ps, and I alert on staleness of output, not just on the PID."

---

## 2. Strategy process dies right at market open, exit code 137

**Situation:** Every day around 09:30 a strategy/risk process disappears. No error in its own log. The supervisor reports `exit status 137`.

**Investigate**
```bash
# 137 - 128 = 9 → SIGKILL. Nobody typed kill -9, so who did?
ps aux --sort=-%mem | head            # who uses the most RAM?
dmesg | grep -i -E 'killed process|out of memory'   # kernel log (Ch3/Ch7 go deeper)
```

**Root cause:** the **OOM killer**. At the open, message volume spikes, every process allocates more memory, RAM runs out, and the kernel picks a big process and sends it SIGKILL. The program gets no chance to log anything, which is why its own log is silent.

**Real evidence from my lab:** on the 954 MB VM, `ps aux --sort=-%mem` showed **netdata using 10.6% + 8.4% ≈ 19% of RAM**. A monitoring tool eating a fifth of RAM on a small box is exactly the kind of thing that pushes the real workload into OOM.
```
USER     PID    %CPU %MEM    VSZ    RSS  COMMAND
netdata  392831  1.8 10.6  743560 104180 /usr/sbin/netdata ...
root     364     0.0  8.9  177508  87264 .../systemd-journald
netdata  393447  0.2  8.4 1535012  82588 .../go.d.plugin 1
```

**Fix:** reduce memory use on the box (move or trim heavy side-processes), add RAM, or limit the noisy neighbour (cgroups, Ch8).

**Prevent:** alert on memory (RSS, not VSZ) before the open; capacity-test with open-time message rates.

**Interview line:** "137 = 128 + 9 = SIGKILL. If no human sent it, check the OOM killer in the kernel log first."

---

## 3. "I used kill -9 and now it won't start again"

**Situation:** An order gateway was slow to stop, so an engineer ran `kill -9` straight away. Restarting it now fails:
```
gateway: cannot start: /var/run/gateway.lock: File exists
```
Or worse: the day's trade-log file is **half written** (the last line is cut off), and the morning reconciliation script fails on it.

**Root cause:** SIGKILL gives **no cleanup**: lock files aren't removed, buffers aren't flushed to disk, and connections to the exchange aren't closed cleanly (some venues then treat the session as still logged in).

**Fix:** confirm the old process is really gone (`ps aux | grep gateway`), then remove the stale lock, and check and repair the log tail (`tail -5 trades.log`).

**Prevent:** the order is always **TERM, wait, then KILL**:
```bash
kill <pid>          # TERM: please shut down cleanly
sleep 10
ps -p <pid> && kill -9 <pid>   # only if still alive
```

**Interview line:** "kill -9 is the last resort. TERM lets the process flush, release locks and log off the exchange cleanly."

---

## 4. Even `kill -9` doesn't remove the process

**Situation:** A risk-report process hangs. TERM does nothing, KILL does nothing; it's still in `ps`.

**Investigate**
```bash
ps -o pid,stat,cmd -p <pid>
```
- **STAT = D** (uninterruptible sleep): stuck **inside the kernel**, waiting on I/O, typically a dead network share (NFS) or a failing disk. Signals are only delivered when it comes back from the kernel, which it never does.
- **STAT = Z** (zombie): it's **already dead**. Only its entry remains because the **parent** never collected its exit status.

**Fix:**
- D: fix the storage or network path (remount, restore the share); sometimes only a reboot clears it.
- Z: fix or restart the **parent** process; zombies take no CPU or RAM, only a PID slot.

**Interview line:** "kill -9 can't beat D state, because the process is stuck in the kernel. A zombie is already dead, so you deal with the parent."

---

## 5. A job dies every time the engineer logs out

**Situation:** A support engineer starts a historical-data download with `./download_ticks.sh &` over SSH, goes home, and next morning it stopped at 18:05, exactly when they closed their laptop.

**Root cause:** closing the SSH session sends **SIGHUP** (hang-up) to jobs of that shell, and they exit.

**Fix / prevent:**
- `nohup ./download_ticks.sh > dl.log 2>&1 &` (ignores HUP, output to a file)
- or run it inside **tmux** (detach with Ctrl-b d; it survives logout, like my dual-terminal)
- for anything recurring: a systemd service or timer (Ch6)

**Interview line:** "Background with & isn't enough over SSH. Use nohup or tmux, and for anything production, systemd."

---

## 6. The cron job "worked" for weeks, but backups were empty 🧪

**Situation:** A nightly job copies the trading config and end-of-day positions to backup. Someone wrote it as `... >/dev/null 2>&1` "to stop the cron emails". Weeks later, after a disk failure, the backups turn out to be empty.

**Real run on my Pi:**
```
$ cp /nonexistent/config.yaml backup/ >/dev/null 2>&1; echo "exit=$?"
silent run, exit=1                         <- failed, but nobody saw anything

$ cp /nonexistent/config.yaml backup/; echo "exit=$?"
cp: cannot stat '/nonexistent/config.yaml': No such file or directory
exit=1                                     <- the error that was being thrown away
```

**Root cause:** `2>/dev/null` sent the **error messages into the black hole**, and nobody checked `$?`.

**Fix / prevent:**
- Send output to a **log file**, not /dev/null: `>> /var/log/backup.log 2>&1`
- Check exit status: `cp ... || echo "BACKUP FAILED" >&2`
- Alert on failure, and **test restores**, not just backups.

**Interview line:** "/dev/null is fine for noise you've understood, never for errors from a job that matters."

---

## 7. The strategy connected to UAT instead of PROD (or the other way round!) 🧪

**Situation:** The startup script does `FEED_ENV=prod` and then launches the feed handler. The handler logs `env=uat` and connects to the test venue. (The scary reverse: a test run that connects to **production**.)

**Real run on my Pi:**
```
$ FEED_ENV=prod
$ bash -c 'echo "child sees FEED_ENV=[${FEED_ENV:-<empty, defaulting to uat>}]"'
child sees FEED_ENV=[<empty, defaulting to uat>]     <- NOT passed to the child

$ export FEED_ENV
$ bash -c 'echo "child sees FEED_ENV=[$FEED_ENV]"'
child sees FEED_ENV=[prod]                           <- now it is
```

**Root cause:** a **shell variable** is not an **environment variable** until you `export` it. Child processes only get exported variables.

**Fix:** `export FEED_ENV=prod`. Check what a running process really has: `cat /proc/<pid>/environ | tr '\0' '\n'` (more in Ch3/Ch8).

**Prevent:** programs should **refuse to start** if the environment isn't set, not silently default to something.

**Interview line:** "Shell vs environment variable: only exported ones are inherited by child processes."

---

## 8. "command not found" only in cron, or the wrong version runs

**Situation A:** `risk_report` runs fine when you type it, but the cron job fails with `risk_report: command not found`.
**Situation B:** after an upgrade, the old version of a tool keeps running.

**Investigate**
```bash
echo $PATH                  # my interactive PATH
which risk_report           # which file actually runs (Ch2 L3)
type -a python3             # every match, in PATH order
```

**Root cause:** cron runs with a **tiny PATH** (often just /usr/bin:/bin), so things in /usr/local/bin or ~/bin aren't found. In B, an old copy sits in a directory that comes **earlier** in PATH.

**Fix:** use **full paths** in scripts and cron (`/opt/risk/bin/risk_report`), or set PATH at the top of the script.

**Interview line:** "PATH is searched left to right, and cron's environment isn't my login environment, so scripts use absolute paths."

---

## 9. Morning incident: "lots of order rejects, which symbol?" 🧪

**Situation:** At 09:30 the desk sees many rejected orders. You have 2 minutes to say what's going on.

**Real run on my Pi** (fake log):
```bash
grep REJECT orders.log | cut -d' ' -f3,4 | sort | uniq -c | sort -rn
```
```
      3 ETHUSD price_band
      1 SOLUSD max_qty
```
(`cut -d' ' -f3,4` = take fields 3 and 4 separated by spaces; a preview of later text tools.)

**Answer for the desk:** "Mostly ETHUSD hitting the **price band** check": likely a bad reference price for that one symbol, not a system-wide outage.

**Live watching:** `tail -f orders.log | grep REJECT` during the open.

**Real-world twin from my lab:** the same pipeline on the VM's auth log found **847 failed SSH logins from 61 IPs**: same technique, security instead of trading.

**Interview line:** "grep → cut → sort → uniq -c → sort -rn is my 30-second log triage."

---

## 10. Service in a restart loop: the binary is gone (real incident INC-001)

**Situation (real, from my VM):** a webhook service restarted **5,579+ times**; systemd reported `203/EXEC`.

**Investigate with Ch2 tools:**
```bash
ls -l /path/to/venv/bin/python     # No such file or directory  → ENOENT
find / -name 'tv-webhook*' 2>/dev/null
```

**Root cause:** the Python virtual environment the service points to was **deleted**; the service can't **exec** its program (remember fork/exec from Ch1), crashes, restarts, forever.

**Fix:** planned for Ch6 (`systemctl disable --now`, then rebuild properly). Write-up: trading-infra-lab `incidents/INC-001`.

**Interview line:** "Read the first error. ENOENT on the executable means the file it's trying to exec doesn't exist. Restarting won't help."

---

## 11. "Disk full" at the worst moment

**Situation:** A gateway starts failing to write: `No space left on device`. Debug logging was left on since yesterday.

**Investigate**
```bash
df -h                                   # which filesystem is full (Ch4)
find /var/log -size +500M 2>/dev/null   # big files
ls -lhS /var/log/gateway | head         # largest first
```

**Fix:** compress or move old logs; **don't `rm` a log file a process still has open** (space isn't freed until the process closes it; Ch8 `lsof`). Truncating with `> big.log` frees the space instead.

**Prevent:** log rotation, disk alerts at 80%, debug logging off in prod.

**Interview line:** "`> file` truncates safely; rm on an open file doesn't free space until the process closes it."

---

## 12. The app runs as root and an accident wipes it out

**Situation:** A cleanup script with a bug runs `rm -rf $DIR/*`, and `$DIR` is empty. The script runs **as root**, so it becomes `rm -rf /*`.

**Root cause:** no **least privilege** (Ch1): the app ran as UID 0. Root is still user mode, but the kernel lets it touch everything.

**Prevent:**
- Run each service as its **own user** (e.g. `feed`) with access only to its own folders: this is my **Lesson 6 / trading-infra-lab task**.
- In scripts: `set -u` (fail on unset variables), and test the path before deleting.

**Interview line:** "Every service gets its own unprivileged user. Root only for what truly needs root."

---

## 13. A machine rebooted overnight and nobody knows why (real incident INC-002)

**Situation (real, my Pi):** the previous boot ended abruptly on 2026-11-07 at 21:42:39: no clean shutdown in the logs, no OOM.

**What I learned so far applies:** "no clean shutdown + no kernel error" points away from software and towards **power or hardware** (the Pi has a known flaky supply and a USB boot drive). Investigation continues in later chapters (`journalctl -b -1`, Ch7).

**Trading angle:** a box that silently reboots during market hours is a P1 incident; the postmortem lives in trading-infra-lab `incidents/INC-002`.

---

## Cheat sheet: symptom → first command

| Symptom | First thing I run |
|---|---|
| Data stopped, process "alive" | `ps -o pid,stat,cmd -p <pid>` (look for **T**) |
| Process vanished, exit 137 | `ps aux --sort=-%mem \| head`, then the kernel log for OOM |
| Won't stop | `kill <pid>` → wait → `kill -9 <pid>` |
| Won't die even with -9 | `ps` STAT: **D** = stuck I/O, **Z** = fix the parent |
| Job died at logout | use `nohup` / tmux / systemd |
| Silent failure | remove `>/dev/null 2>&1`, check `$?` |
| Wrong environment | `export`, check `/proc/<pid>/environ` |
| Works by hand, fails in cron | `which`, `echo $PATH`, use absolute paths |
| "What's failing?" in logs | `grep \| sort \| uniq -c \| sort -rn` |
| Crash loop | read the **first** error (ENOENT? permission?) |
| Disk full | `df -h`, `find -size +500M`, truncate, don't rm open files |

---

## My own hands-on run of the drills (typed by me, 2026-11-11)

> ⚠️ I ran these in the **top pane = Raspberry Pi** (prompt `rabindrakunwar@rabindrakunwar`), not the VM. The VM run (bottom pane, prompt `ubuntu@bot-vnic`) is still to do.

**Drill 1: frozen feed**
```
$ (while true; do echo "$(date +%T) TICK BTCUSD"; sleep 1; done) > feed.log &
[1] 1101740
$ F=$!
$ kill -STOP $F
[1]+  Stopped        ( while true; do ... done ) > feed.log
$ ps -o pid,stat,cmd -p $F
    PID STAT CMD
1101740 T    -bash              <- T = stopped; CMD is "-bash" (see below)
$ tail -1 feed.log; date +%T
23:32:59 TICK BTCUSD            <- last tick
23:33:45                        <- now: 46 seconds without data!
$ kill -CONT $F
$ tail -3 feed.log
23:34:00 TICK BTCUSD            <- flowing again
23:34:01 TICK BTCUSD
23:34:02 TICK BTCUSD
$ kill $F
[1]+  Terminated     ( while true; ... ) > feed.log
```
- Why is CMD `-bash`? `( ... )` makes the shell **fork** a copy of itself (a subshell) to run the loop. It never `exec`s a new program, so it keeps the parent's name, `-bash` (the `-` means login shell). This is fork vs exec from Ch1.
- The shell says **Stopped** even though I used `kill -STOP` instead of Ctrl-Z: the shell sees any stopped job of its own.
- 46 s of silence: in a real firm this is a P1 incident at market open.

**Drill 3: stale lock**
```
$ sleep 600 & echo $! > gateway.lock
[1] 1102174
$ kill -9 $(cat gateway.lock)
[1]+  Killed          sleep 600
$ set -C; echo $$ > gateway.lock; set +C
-bash: gateway.lock: cannot overwrite existing file      <- "gateway refuses to start"
$ ps -p $(cat gateway.lock) || echo "stale lock, safe to remove"
    PID TTY          TIME CMD                            <- only the header: PID gone
stale lock, safe to remove
$ rm gateway.lock
```
- `$(cat gateway.lock)` = **command substitution**: run `cat`, paste its output (the PID) into the command.
- `ps -p` with a dead PID prints only the header and returns a non-zero exit, so `||` runs the echo.

**Drill 6: /dev/null hides errors**
```
$ cp /nonexistent/config.yaml backup/ >/dev/null 2>&1; echo "exit=$?"
exit=1                                         <- failed silently
$ cp /nonexistent/config.yaml backup/; echo "exit=$?"
cp: cannot stat '/nonexistent/config.yaml': No such file or directory
exit=1
```

**Drill 7: export**
```
$ FEED_ENV=prod
$ bash -c 'echo "child sees: [$FEED_ENV]"'
child sees: []           <- shell variable only
$ export FEED_ENV
$ bash -c 'echo "child sees: [$FEED_ENV]"'
child sees: [prod]       <- now an environment variable
```
(I typed `export FEED_ENV` twice; harmless, exporting again changes nothing.)

**Drill 8: cron PATH**
```
$ PATH=$PATH:~/drills/bin
$ risk_report
risk report OK
$ env -i PATH=/usr/bin:/bin bash -c 'risk_report'
bash: line 1: risk_report: command not found     <- "cron" can't find it
$ env -i PATH=/usr/bin:/bin bash -c '~/drills/bin/risk_report'
risk report OK                                   <- full path always works
```
`env -i` = start with an **empty** environment, the way cron does.

**Drill 9: reject triage**
```
$ grep REJECT orders.log | cut -d' ' -f3,4 | sort | uniq -c | sort -rn
      3 ETHUSD price_band
      1 SOLUSD max_qty
```

**Cleanup:** `jobs` (empty, so nothing is left running) → `cd ~ && rm -r ~/drills`.
