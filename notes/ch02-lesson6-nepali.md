# Lesson 6 (Permissions): VM lab नेपालीमा (2026-11-13)

> यो file `nepali` branch मा मात्र commit गर्ने।

| Command / Output | अर्थ |
|---|---|
| `cd ~/p` + Tab Tab → `permlab/ portfolio_dashboard/` | Tab दुई पटक थिच्दा `p` बाट सुरु हुने सबै नाम देखाउँछ। अझ अक्षर टाइप गर्नुपर्छ |
| `drwxrwxr-x ... d` | `d` = directory, **775**। Owner र group ले सबै गर्न सक्छन्, अरूले हेर्न र भित्र जान मात्र |
| `-rw-rw-r-- ... f` | `-` = file, **664**। umask 002 ले गर्दा नयाँ file यस्तै बन्छ |
| `chmod 600 f` → `-rw-------` | मात्र म पढ्न/लेख्न सक्छु। Group र अरू: केही पनि होइन (SSH key जस्तो) |
| `chmod 755 f` → `-rwxr-xr-x` (हरियो) | सबैले पढ्न र चलाउन सक्छन्, लेख्न म मात्र। हरियो रङ = चलाउन मिल्ने file |
| `./s.sh` → `Permission denied` | File मा **x** (execute) छैन, त्यसैले चलाउन दिएन |
| `chmod +x s.sh` → `I run!` | x थपेपछि script चल्यो ✅ |
| `l -l ...` | `l` भनेको Ubuntu को **alias** (छोटो नाम) हो: `ls -CF`। `ll` = `ls -alF` |
| `/etc/shadow` → `-rw-r----- root shadow` | Password hash भएको file। Root र shadow group मात्र पढ्न सक्छन् |
| `/usr/bin/passwd` → `-rwsr-xr-x`, रातो, `*` | **s** = setuid: यो program **root** भएर चल्छ, त्यसैले साधारण user ले पनि आफ्नो password बदल्न सक्छ। रातो रङ = ls ले "ध्यान दिनू, setuid!" भनेको। `*` = चलाउन मिल्ने |
| `ln -s /etc/hostname myhost` | `myhost` नामको **shortcut** (symlink) बनायो, `/etc/hostname` तिर देखाउने |
| `lrwxrwxrwx ... 13 myhost -> /etc/hostname` | `l` = link। Size **13** किन? Link ले path को अक्षर मात्र राख्छ: `/etc/hostname` = 13 अक्षर |
| `cat myhost` → `bot-vnic` | Link खोल्दा असली file खुल्यो। `bot-vnic` = VM को नाम |
| `cd ~; rm -r ~/permlab` | सफा गर्यो ✅ |

**Pi सँग तुलना:** नतिजा उस्तै। फरक मात्र passwd को size: Pi (ARM) मा 142,552 bytes, VM (x86) मा 64,152 bytes, किनभने CPU फरक भएकाले program को build फरक हुन्छ।
