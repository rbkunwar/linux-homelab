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

---

## Lesson 2: The kernel (section 1.3, PDF p.30–34)

Almost everything the kernel does revolves around **main memory**. It splits memory up, gives each process its own share, and makes sure every process stays inside it.

The kernel's **4 jobs**:

| Job | In one line |
|---|---|
| **Processes** | decides which process gets to use the CPU |
| **Memory** | tracks all memory: what belongs to which process, what's shared, what's free |
| **Device drivers** | operates the hardware for processes |
| **System calls and support** | the way processes ask the kernel to do things |

### 1.3.1 Process management
- Process management = **starting, pausing, resuming, scheduling, and terminating** processes.
- One CPU core runs **one process at a time**. Each process gets a tiny **time slice**, then the next one runs. This switch is a **context switch**.
- The slices are so short that it *looks* like everything runs at once: **multitasking**.
- **When does the kernel run?** Between time slices, during a context switch.
- The 7 steps of a context switch:
  1. The CPU's **timer interrupts** the process, switches to **kernel mode**, and hands control to the kernel.
  2. The kernel **saves the state** of the CPU and memory (so the process can resume later).
  3. The kernel does any pending work (e.g. collecting I/O data).
  4. The kernel **picks the next process** from those ready to run.
  5. It prepares memory, then the CPU, for that process.
  6. It tells the CPU **how long the new time slice lasts**.
  7. It switches the CPU to **user mode** and hands control to the process.
- With multiple CPUs (the Pi has 4 cores), several processes really do run at the same time, but the kernel still context-switches to keep all cores busy.

**Real Pi output:**
```
$ grep ctxt /proc/stat
ctxt 165576820                      ← context switches since boot (about 1 day)

$ vmstat 1 3                        ← "cs" column = context switches per second
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0 518088 143572 2139332    0    0     0     0 3773 4358  3  5 93  0
```
About 165 million switches in about 25 hours, roughly 1,800 per second, even when the Pi looks idle.

### 1.3.2 Memory management
The rules the kernel must enforce:
- The kernel has its **own private memory** that processes can't access.
- Each process gets **its own section** of memory.
- One process **cannot read another's private memory**.
- Processes **can share** memory (when allowed).
- Some memory can be **read-only**.
- The system can use **more memory than physically exists** by using **disk as extra memory** (swap).

How: the CPU's **MMU (memory management unit)** enables **virtual memory**.
- Each process acts **as if it had the whole machine to itself**.
- When it touches memory, the MMU **translates** the process's address to the real physical address using a **memory address map** (its implementation is called a **page table**).
- On each context switch, the kernel swaps in the next process's map.

**Real Pi output:**
```
$ getconf PAGESIZE
4096                                ← memory is managed in 4 KB "pages"
$ swapon --show
NAME      TYPE  SIZE USED PRIO
/swapfile file 1024M   0B   -1     ← 1 GB of disk used as extra memory (unused right now)
```

### 1.3.3 Device drivers
- Devices are normally only accessible in **kernel mode**, because bad access (e.g. a process switching off the power) could crash the machine.
- Different devices that do the **same job** (two network cards) have **different programming interfaces**.
- **Device drivers** live in the kernel and give programs **one uniform interface**, so software doesn't care which brand of hardware it's using.

**Real Pi output:**
```
$ lsmod | wc -l
93                                  ← about 92 kernel modules (drivers and features) loaded
$ lsmod | head -3
Module                  Size  Used by
wireguard             102400  0
libcurve25519          32768  1 wireguard
```

### 1.3.4 System calls and support
- A **system call (syscall)** is a request from a process to the kernel to do something it can't do alone. Opening, reading, and writing files are all syscalls.
- The two key syscalls for starting programs:
  - **`fork()`**: the kernel makes a **nearly identical copy** of the process.
  - **`exec(program)`**: the kernel **loads a new program, replacing** the current process.
- Every new user process (except **init**, PID 1) starts via `fork()`. Usually `exec()` follows, to run a different program.
- Typing `ls` in a shell: the **shell forks** a copy of itself, then **the copy execs `ls`**.

```
shell ──fork()──► shell + copy of shell ──exec(ls)──► shell + ls
```

- Syscalls are written with `()` because of how they look in C. `exec()` is really a family of calls (`execve` is the one you'll see). **Threads** are a variant of processes (Chapter 8).

**Real Pi output: watching fork + exec with `strace`:**
```
$ strace -f -e trace=clone,execve bash -c 'ls; true'
execve("/usr/bin/bash", ["bash", "-c", "ls; true"], ...) = 0     ← bash starts
clone(...) = 336186                                               ← fork(): copy made, PID 336186
[pid 336186] execve("/usr/bin/ls", ["ls"], ...) = 0              ← the copy becomes ls
Linux.pdf  README.md  dual-terminal.sh  notes  progress.md
[pid 336186] +++ exited with 0 +++                                ← ls finishes
```
(On Linux, `fork()` is implemented by the `clone` syscall.)

### My own strace run, explained line by line (2026-11-08)
I ran `strace -f -e trace=clone,execve bash -c 'ls; true'` from my home folder:
```
execve("/usr/bin/bash", ["bash", "-c", "ls; true"], 0x...e0d8 /* 30 vars */) = 0
clone(child_stack=NULL, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLDstrace: Process 339112 attached
, child_tidptr=0xffff923500f0) = 339112
[pid 339112] execve("/usr/bin/ls", ["ls"], 0x...e940 /* 30 vars */) = 0
Crypto  Desktop  Documents ... linux-project ... trend_paper
[pid 339112] +++ exited with 0 +++
```
| Line | Meaning |
|---|---|
| `execve("/usr/bin/bash", [...]) = 0` | **exec**: bash is loaded and starts. `/* 30 vars */` = 30 environment variables passed in. `= 0` = success. |
| `clone(... SIGCHLD ...) = 339112` | **fork**: bash copies itself. The kernel returns the child's PID, **339112**. `SIGCHLD` = "tell me (the parent) when the child finishes". |
| `strace: Process 339112 attached` | strace's own message (from `-f`, follow children), printed in the middle of the clone line because both write at the same time. Not an error. |
| `[pid 339112] execve("/usr/bin/ls", ["ls"], ...) = 0` | **exec**: the copy (PID 339112) **replaces itself with ls**. `["ls"]` = the argument list. |
| `Crypto Desktop ...` | ls's normal output: the contents of my home folder. |
| `+++ exited with 0 +++` | ls finished. **Exit code 0 = success** (non-zero = error). |

- **Why `; true`?** With only one command (`bash -c 'ls'`), bash skips the fork and just **execs ls directly** (exec without fork). Adding a second command forces bash to fork for `ls`. `true` is a shell built-in, so it runs inside bash with no new process.
- **Yellow `23:39 [5/299]` at the top right:** tmux **copy mode** (scrolling). I scrolled up with the mouse; `[5/299]` = 5 lines up out of 299 in the history. Press `q` to leave copy mode and get back to the prompt.

**Exec without fork:**
```
$ bash -c 'echo "my shell PID: $$"; ps -o pid,ppid,cmd'
my shell PID: 336187
 336187  336177 ps -o pid,ppid,cmd       ← same PID! bash exec'd into ps for its last command
```

**Pseudodevices:** they look like devices but are **pure software** inside the kernel.
- `/dev/random` / `/dev/urandom`: random numbers (hard to do securely outside the kernel)
- `/dev/null`: throws away everything written to it
- `/dev/zero`: endless zeros

Opening a pseudodevice is still a system call, so processes can't fully avoid syscalls.
```
$ head -c 16 /dev/urandom | base64
L0rx7x4D2qsHt7PGTCdCkw==
$ ls -l /dev/null /dev/random
crw-rw-rw- 1 root root 1, 3 ... /dev/null      ← "c" = character device
crw-rw-rw- 1 root root 1, 8 ... /dev/random
```

### Interview answers
- **What happens when you type `ls`?** "The shell calls `fork()` to create a copy of itself, the child calls `exec()` to replace itself with `ls`, the kernel loads and runs `ls`, and when `ls` exits the shell gets notified (SIGCHLD) and shows the prompt again."
- **What is a context switch?** "When the kernel stops one process at the end of its time slice, saves its state, and loads another process onto the CPU."
- **What is virtual memory?** "Each process gets its own address space and thinks it owns all memory; the CPU's MMU translates those addresses to physical RAM using page tables, which isolates processes and allows swap."
- **What is a system call?** "A request from a user-mode process to the kernel, e.g. open/read/write/fork/exec."
