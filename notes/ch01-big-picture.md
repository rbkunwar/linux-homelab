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
