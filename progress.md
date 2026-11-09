# Linux learning progress

Book: **How Linux Works, 3rd Edition** by Brian Ward (`Linux.pdf`, 467 pages)
Goal: master Linux and land a job as a Linux engineer.
Lab machines: this Raspberry Pi (Ubuntu 26.04) and the VM (`ssh vm`, Ubuntu 24.04). Open both with `./dual-terminal.sh`.

**PDF page = book page + 26.** For example, book page 1 (Chapter 1) is PDF page 27.

How each section works: **Learn** it (what and why), **Lab** it (hands-on on the Pi/VM), **Check** it (quiz), and note the **Interview** angle.
Mark a section `[x]` only after the quiz is passed.

Priority: **Core** = commonly needed on the job and asked in interviews. **Medium** = useful background. **Low** = skim.

## Chapter 1: The Big Picture
Book p.1 (PDF p.27) · Priority: Core

- [x] 1.1 Levels and Layers of Abstraction in a Linux System
- [x] 1.2 Hardware: Understanding Main Memory
- [x] 1.3 The Kernel
- [x] 1.4 User Space
- [x] 1.5 Users
- [x] 1.6 Looking Forward

## Chapter 2: Basic Commands and Directory Hierarchy
Book p.11 (PDF p.37) · Priority: Core

- [ ] 2.1 The Bourne Shell: /bin/sh
- [ ] 2.2 Using the Shell
- [ ] 2.3 Basic Commands
- [ ] 2.4 Navigating Directories
- [ ] 2.5 Intermediate Commands
- [ ] 2.6 Changing Your Password and Shell
- [ ] 2.7 Dot Files
- [ ] 2.8 Environment and Shell Variables
- [ ] 2.9 The Command Path
- [ ] 2.10 Special Characters
- [ ] 2.11 Command-Line Editing
- [ ] 2.12 Text Editors
- [ ] 2.13 Getting Online Help
- [ ] 2.14 Shell Input and Output
- [ ] 2.15 Understanding Error Messages
- [ ] 2.16 Listing and Manipulating Processes
- [ ] 2.17 File Modes and Permissions
- [ ] 2.18 Archiving and Compressing Files
- [ ] 2.19 Linux Directory Hierarchy Essentials
- [ ] 2.20 Running Commands as the Superuser
- [ ] 2.21 Looking Forward

## Chapter 3: Devices
Book p.47 (PDF p.73) · Priority: Core

- [ ] 3.1 Device Files
- [ ] 3.2 The sysfs Device Path
- [ ] 3.3 dd and Devices
- [ ] 3.4 Device Name Summary
- [ ] 3.5 udev
- [ ] 3.6 In-Depth: SCSI and the Linux Kernel

## Chapter 4: Disks and Filesystems
Book p.69 (PDF p.95) · Priority: Core

- [ ] 4.1 Partitioning Disk Devices
- [ ] 4.2 Filesystems
- [ ] 4.3 Swap Space
- [ ] 4.4 The Logical Volume Manager
- [ ] 4.5 Looking Forward: Disks and User Space
- [ ] 4.6 Inside a Traditional Filesystem

## Chapter 5: How the Linux Kernel Boots
Book p.117 (PDF p.143) · Priority: Core

- [ ] 5.1 Startup Messages
- [ ] 5.2 Kernel Initialization and Boot Options
- [ ] 5.3 Kernel Parameters
- [ ] 5.4 Boot Loaders
- [ ] 5.5 GRUB Introduction
- [ ] 5.6 UEFI Secure Boot Problems
- [ ] 5.7 Chainloading Other Operating Systems
- [ ] 5.8 Boot Loader Details

## Chapter 6: How User Space Starts
Book p.137 (PDF p.163) · Priority: Core

- [ ] 6.1 Introduction to init
- [ ] 6.2 Identifying Your init
- [ ] 6.3 systemd
- [ ] 6.4 System V Runlevels
- [ ] 6.5 System V init
- [ ] 6.6 Shutting Down Your System
- [ ] 6.7 The Initial RAM Filesystem
- [ ] 6.8 Emergency Booting and Single-User Mode
- [ ] 6.9 Looking Forward

## Chapter 7: System Configuration: Logging, System Time, Batch Jobs, and Users
Book p.167 (PDF p.193) · Priority: Core

- [ ] 7.1 System Logging
- [ ] 7.2 The Structure of /etc
- [ ] 7.3 User Management Files
- [ ] 7.4 getty and login
- [ ] 7.5 Setting the Time
- [ ] 7.6 Scheduling Recurring Tasks with cron and Timer Units
- [ ] 7.7 Scheduling One-Time Tasks with at
- [ ] 7.8 Timer Units Running as Regular Users
- [ ] 7.9 User Access Topics
- [ ] 7.10 Pluggable Authentication Modules
- [ ] 7.11 Looking Forward

## Chapter 8: A Closer Look at Processes and Resource Utilization
Book p.199 (PDF p.225) · Priority: Core

- [ ] 8.1 Tracking Processes
- [ ] 8.2 Finding Open Files with lsof
- [ ] 8.3 Tracing Program Execution and System Calls
- [ ] 8.4 Threads
- [ ] 8.5 Introduction to Resource Monitoring
- [ ] 8.6 Control Groups (cgroups)
- [ ] 8.7 Further Topics

## Chapter 9: Understanding Your Network and Its Configuration
Book p.223 (PDF p.249) · Priority: Core

- [ ] 9.1 Network Basics
- [ ] 9.2 Packets
- [ ] 9.3 Network Layers
- [ ] 9.4 The Internet Layer
- [ ] 9.5 Routes and the Kernel Routing Table
- [ ] 9.6 The Default Gateway
- [ ] 9.7 IPv6 Addresses and Networks
- [ ] 9.8 Basic ICMP and DNS Tools
- [ ] 9.9 The Physical Layer and Ethernet
- [ ] 9.10 Understanding Kernel Network Interfaces
- [ ] 9.11 Introduction to Network Interface Configuration
- [ ] 9.12 Boot-Activated Network Configuration
- [ ] 9.13 Problems with Manual and Boot-Activated Network Configuration
- [ ] 9.14 Network Configuration Managers
- [ ] 9.15 Resolving Hostnames
- [ ] 9.16 Localhost
- [ ] 9.17 The Transport Layer: TCP, UDP, and Services
- [ ] 9.18 Revisiting a Simple Local Network
- [ ] 9.19 Understanding DHCP
- [ ] 9.20 Automatic IPv6 Network Configuration
- [ ] 9.21 Configuring Linux as a Router
- [ ] 9.22 Private Networks (IPv4)
- [ ] 9.23 Network Address Translation (IP Masquerading)
- [ ] 9.24 Routers and Linux
- [ ] 9.25 Firewalls
- [ ] 9.26 Ethernet, IP, ARP, and NDP
- [ ] 9.27 Wireless Ethernet
- [ ] 9.28 Summary

## Chapter 10: Network Applications and Services
Book p.269 (PDF p.295) · Priority: Core

- [ ] 10.1 The Basics of Services
- [ ] 10.2 A Closer Look
- [ ] 10.3 Network Servers
- [ ] 10.4 Pre-systemd Network Connection Servers: inetd/xinetd
- [ ] 10.5 Diagnostic Tools
- [ ] 10.6 Remote Procedure Calls
- [ ] 10.7 Network Security
- [ ] 10.8 Looking Forward
- [ ] 10.9 Network Sockets
- [ ] 10.10 Unix Domain Sockets

## Chapter 11: Introduction to Shell Scripts
Book p.291 (PDF p.317) · Priority: Core

- [ ] 11.1 Shell Script Basics
- [ ] 11.2 Quoting and Literals
- [ ] 11.3 Special Variables
- [ ] 11.4 Exit Codes
- [ ] 11.5 Conditionals
- [ ] 11.6 Loops
- [ ] 11.7 Command Substitution
- [ ] 11.8 Temporary File Management
- [ ] 11.9 Here Documents
- [ ] 11.10 Important Shell Script Utilities
- [ ] 11.11 Subshells
- [ ] 11.12 Including Other Files in Scripts
- [ ] 11.13 Reading User Input
- [ ] 11.14 When (Not) to Use Shell Scripts

## Chapter 12: Network File Transfer and Sharing
Book p.315 (PDF p.341) · Priority: Core

- [ ] 12.1 Quick Copy
- [ ] 12.2 rsync
- [ ] 12.3 Introduction to File Sharing
- [ ] 12.4 Sharing Files with Samba
- [ ] 12.5 SSHFS
- [ ] 12.6 NFS
- [ ] 12.7 Cloud Storage
- [ ] 12.8 The State of Network File Sharing

## Chapter 13: User Environments
Book p.335 (PDF p.361) · Priority: Core

- [ ] 13.1 Guidelines for Creating Startup Files
- [ ] 13.2 When to Alter Startup Files
- [ ] 13.3 Shell Startup File Elements
- [ ] 13.4 Startup File Order and Examples
- [ ] 13.5 Default User Settings
- [ ] 13.6 Startup File Pitfalls
- [ ] 13.7 Further Startup Topics

## Chapter 14: A Brief Survey of the Linux Desktop and Printing
Book p.347 (PDF p.373) · Priority: Low (desktop/printing, rarely asked)

- [ ] 14.1 Desktop Components
- [ ] 14.2 Are You Running Wayland or X?
- [ ] 14.3 A Closer Look at Wayland
- [ ] 14.4 A Closer Look at the X Window System
- [ ] 14.5 D-Bus
- [ ] 14.6 Printing
- [ ] 14.7 Other Desktop Topics

## Chapter 15: Development Tools
Book p.363 (PDF p.389) · Priority: Medium

- [ ] 15.1 The C Compiler
- [ ] 15.2 make
- [ ] 15.3 Lex and Yacc
- [ ] 15.4 Scripting Languages
- [ ] 15.5 Java
- [ ] 15.6 Looking Forward: Compiling Packages

## Chapter 16: Introduction to Compiling Software from C Source Code
Book p.385 (PDF p.411) · Priority: Medium

- [ ] 16.1 Software Build Systems
- [ ] 16.2 Unpacking C Source Packages
- [ ] 16.3 GNU Autoconf
- [ ] 16.4 Installation Practice
- [ ] 16.5 Applying a Patch
- [ ] 16.6 Troubleshooting Compiles and Installations
- [ ] 16.7 Looking Forward

## Chapter 17: Virtualization
Book p.401 (PDF p.427) · Priority: Core

- [ ] 17.1 Virtual Machines
- [ ] 17.2 Containers
- [ ] 17.3 Runtime-Based Virtualization

## Beyond the book: job skills to add

The book explains how Linux works but skips some day-to-day job skills. We'll cover these alongside the chapters:

- [ ] Package management in depth: `apt`/`dpkg` (Ubuntu) and `dnf`/`rpm` (Red Hat family)
- [ ] Red Hat family systems (RHEL, Rocky, Alma), which are common in enterprise jobs and used by the RHCSA exam
- [ ] Security hardening: SSH hardening, `ufw`/`firewalld`/`nftables`, AppArmor/SELinux, fail2ban
- [ ] Git and version control
- [ ] Containers in practice: Docker/Podman, plus Kubernetes basics
- [ ] Automation: Ansible
- [ ] Web servers and reverse proxies: nginx
- [ ] Monitoring and logs at scale: Prometheus/Grafana, log rotation
- [ ] Backups: rsync, snapshots, restore testing
- [ ] Cloud basics (AWS / Oracle Cloud, where your VM likely lives)
- [ ] A troubleshooting method: "the server is slow", "the site is down", "the disk is full" walkthroughs
- [ ] Interview practice: mock questions per chapter, plus a homelab write-up for your CV

## Session log

| Date | What we covered | Notes |
|---|---|---|
| 2026-11-07 | Set up tmux dual terminal, SSH key + config for the VM, added the book | Topics touched: apt, ssh-keygen, ~/.ssh/config, known_hosts fingerprints, tmux, df -h |
| 2026-11-08 | Ch1 Lesson 1: abstraction, 3 layers, kernel vs user mode, kernel threads, main memory/state/image. Quiz passed | Notes: notes/ch01-big-picture.md. Learned: top/q/Ctrl-c, ps columns, paths (./ vs ~ vs /) |
| 2026-11-08 | Ch1 Lesson 2: kernel jobs, context switch, virtual memory/MMU/page table, drivers, syscalls fork+exec (watched with strace), pseudodevices. Quiz passed | Fixed: Q4 (fork then exec, not what ls does); Q3 re-explained with the hotel |
| 2026-11-09 | Ch1 Lesson 3: user space layers (Figure 1-3 on Pi vs VM), users/UIDs, root (UID 0, still user mode), groups, least privilege; system calls re-explained with cat traces. Quiz passed | Fixed: Q3 least privilege limits damage (not about user mode); Q4 groups = shared file access. Learned: always read the prompt (rebooted VM dropped SSH) |
