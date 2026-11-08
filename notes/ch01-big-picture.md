# Chapter 1: The Big Picture

Book p.1–10 (PDF p.27–36)

## Lesson 1: Abstraction, layers, main memory (sections intro, 1.1, 1.2)

### Abstraction (chapter intro)
- Ignore a component's inner details. Focus on **what it does** and **how to use it**.
- The car example: passenger vs driver. A driver thinks about the car, the controls, and the road.
- **Troubleshooting with abstraction:** split the system into parts, rule out the healthy ones, then dig into the guilty one.
  - "The website is slow": browser → network → server hardware → web server → database.
- The book calls these parts **components** (also known as subsystems, modules, or packages).

### 1.1 Three levels of a Linux system
```
User processes (user space)  ← shell, servers, GUI
Linux kernel                 ← system calls, process mgmt, memory mgmt, device drivers
Hardware                     ← CPU, RAM, disks, network ports
```
- **Kernel** = core of the OS. Lives in memory, tells the CPU what to do next, and is the mediator between hardware and programs.
- **Process** = a running program. A web server is a **user process**.

| | Kernel mode | User mode |
|---|---|---|
| Who | the kernel | user processes |
| Access | unrestricted (all CPU + memory) | restricted (own memory, safe CPU ops) |
| Memory | kernel space | user space |
| Crash | can take down the whole system | only that process dies; the kernel cleans up |

- Hotel analogy: the kernel is the manager with the master key; processes are guests with keys to their own rooms only.
- Permissions still matter: a process with the right permissions *can* do damage, like wiping a disk.
- **Kernel threads** look like processes but run with kernel-space access. They show in `[brackets]` in `ps` (e.g. `[kthreadd]`, PID 2).

### 1.2 Main memory
- RAM = a huge store of **bits** (0/1). The kernel and all processes live in it; all I/O flows through it.
- The CPU is just an operator on memory: it reads instructions and data, and writes results back.
- **State** = a particular arrangement of bits. We describe it in plain words ("waiting for input").
- **Image** = the actual physical arrangement of bits (later: disk image, container image).

### Lab commands
| Command | Shows |
|---|---|
| `uname -r` | kernel version (Pi: `7.0.0-1020-raspi`) |
| `uname -m` | CPU architecture (Pi: `aarch64`, VM: `x86_64`) |
| `nproc` | number of CPU cores (Pi: 4) |
| `free -h` | memory usage |
| `df -h` | disk usage |
| `top` | live CPU and memory per process. **Quit with `q`** |
| `ps -ef` | all processes. Columns: UID (owner), PID, PPID, ..., CMD (name) |

Pi: about 199 processes, of which about 131 were kernel threads.

### `top` explained (real output from my Pi, 2026-11-08)
`top` is covered properly in Chapter 8. These are the basics.

```
top - 23:23:09 up 1 day,  1:32,  2 users,  load average: 0.94, 0.55, 0.51
Tasks: 202 total,   2 running, 200 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.9 us,  1.9 sy,  0.0 ni, 92.3 id,  3.8 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   3777.8 total,    522.4 free,   1215.6 used,   2229.0 buff/cache
MiB Swap:   1024.0 total,   1024.0 free,      0.0 used.   2562.2 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  23874 rabindr+  20   0 6052472 326952 127948 R  41.7   8.5  15:14.50 2.1.284
 334732 rabindr+  20   0   12940   5428   3000 R  16.7   0.1   0:00.03 top
     15 root      20   0       0      0      0 I   8.3   0.0   1:07.06 rcu_preempt
   3130 netdata   20   0 1444336 128824  90832 S   8.3   3.3  17:56.74 go.d.plugin
      1 root      20   0   27884  18616  10872 S   0.0   0.5   1:03.09 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:10.16 kthreadd
```

**Top half: the whole machine**
- **Line 1:** `up 1 day, 1:32` is the uptime. `2 users` counts logged-in sessions. `load average: 0.94, 0.55, 0.51` is the load over the last 1/5/15 minutes.
  - Rule of thumb: compare it to the number of cores (`nproc` = 4). Below 4 is fine; above 4 means work is queuing.
- **Line 2, Tasks:** 202 processes. Most are **sleeping** (waiting for something to do), which is normal and healthy.
- **Line 3, CPU %:**

| Label | Meaning | Mine |
|---|---|---|
| `us` | user programs (user mode) | 1.9 |
| `sy` | the kernel (kernel mode) | 1.9 |
| `id` | idle | 92.3 |
| `wa` | waiting for the disk (high = slow disk) | 3.8 |

- **Lines 4–5, Memory:** `buff/cache` is spare RAM Linux uses to cache files; it's given back when programs need it.
  - **`avail Mem` is the number that matters** (2562 MiB). Don't panic about a small `free`.
  - **Swap** = disk used as extra RAM. `0.0 used` is good.

**Bottom half: one line per process, sorted by CPU**

| Column | Meaning |
|---|---|
| PID | process ID |
| USER | owner |
| S | state: R running, S sleeping, I idle kernel thread |
| %CPU / %MEM | CPU / RAM used now |
| TIME+ | total CPU time since start |
| COMMAND | name |

- `2.1.284` = Claude Code running on the Pi. `go.d.plugin` = netdata (a monitoring tool installed on the Pi).
- `top` doesn't show `[brackets]` the way `ps` does, but `kthreadd` (PID 2) is still a kernel thread.
- PR, NI, VIRT, RES, SHR: skip for now (Chapter 8).

**Keys:** `q` quit · `M` sort by memory · `P` sort by CPU · `1` show each core · `h` help

**Interview:** "How do you check whether a server is overloaded?" → `top`: compare the load average to the core count, check `%Cpu id`/`wa`, check `avail Mem` and swap usage, then see which process is at the top.

### Keys
- `q`: quit screen programs (`top`, `less`, `man`)
- `Ctrl-c`: stop almost any running command

### Mistakes I learned from
- `./script.sh` only works if the script is in the **current** folder. `~/linux-project/dual-terminal.sh` works from anywhere.
- A leading `/` means the root of the whole disk. `~` means my home folder.
- The `$` at the end of the prompt is not part of the command.
- In `ps`, `root` is the **owner** (UID column), not the process name. The name is the CMD column.

### Interview answers
- **Kernel space vs user space:** "The kernel runs in kernel mode with unrestricted access to hardware and memory; programs run in user mode, isolated in their own memory, so a crashing program can't take down the system."
- **"The site is slow":** "Break the system into layers, check each quickly (network, server resources, app, database), rule out the healthy ones, then dig into the guilty one."
- **Pi is slow, what first?** CPU (`top`), memory (`free -h`), disk (`df -h`).
