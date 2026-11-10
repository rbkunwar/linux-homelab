# अहिलेसम्मको सबै सारांश (नेपालीमा)

*२०२६ नोभेम्बर ७ देखि ११ सम्म · Chapter 1 पूरा, Chapter 2 को Lesson 1–2 पूरा, Lesson 3 बाँकी (३ प्रश्न दोहोर्याउन बाँकी)*

---

## 🎯 मेरो लक्ष्य
- **Linux engineer** को जागिर पाउने, विशेषगरी **trading company** मा।
- किताब: **How Linux Works (3rd Edition)**, Brian Ward। हरेक section पढ्ने → हातले गर्ने (lab) → प्रश्नको उत्तर दिने → interview मा कसरी भन्ने भनेर सिक्ने।

---

## 🖥️ मेरो Lab (दुई कम्प्युटर)

| | Raspberry Pi (माथिल्लो pane) | VM (तल्लो pane) |
|---|---|---|
| कहाँ | घरमा, Wi-Fi मा | Cloud मा (internet मा) |
| CPU | ARM (`aarch64`), ४ core | x86_64, २ core |
| RAM | ४ GB | १ GB |
| Ubuntu | 26.04 | 24.04 |
| Prompt | `rabindrakunwar@rabindrakunwar:~$` | `ubuntu@bot-vnic:~$` |

- **tmux** ले एउटै झ्यालमा दुवै देखाउँछ। फेरि खोल्न: `~/linux-project/dual-terminal.sh`
- `Ctrl-b` अनि `d` = session लाई background मा छोड्ने (बन्द हुँदैन)
- Pi बाट VM मा जान: `ssh vm` (Pi को लागि छुट्टै SSH key बनाएको: `~/.ssh/pi_to_vm`)
- ⚠️ **सधैं prompt हेर्ने!** Pane को नाम गलत हुन सक्छ, prompt कहिल्यै झूट बोल्दैन। (मैले VM `sudo reboot` गर्दा तल्लो pane चुपचाप Pi मा फर्किएको थियो।)

---

## 📘 Chapter 1: The Big Picture ✅

### Abstraction
भित्री कुरा बिर्सेर, **"यसले के काम गर्छ"** मा ध्यान दिने। समस्या खोज्दा system लाई टुक्रा-टुक्रा गरेर एक-एक जाँच्ने (गाडी, चलाउने तरिका, सडक)।

### Linux का ३ तह
```
User processes (programs)   ← shell, web server, browser
Kernel (manager)            ← सबैको मालिक
Hardware                    ← CPU, RAM, disk, network
```

### Kernel mode vs User mode
- **Kernel** = होटलको **manager**, सबै कोठाको master key।
- **Program** = **पाहुना**, आफ्नो कोठाको चाबी मात्र। एउटा program crash भए अरूलाई असर गर्दैन।
- ⭐ **root पनि user mode मै चल्छ**, kernel mode मा होइन! (interview trick question)

### Kernel का ४ काम
1. **Process:** CPU एकपटकमा एउटा मात्र program चलाउँछ। साना **time slice** दिएर छिट्टै-छिट्टै फेर्छ (**context switch**)। त्यसैले सबै एकैसाथ चलेजस्तो लाग्छ (multitasking)। मेरो Pi मा १ सेकेन्डमा ~१,८०० पटक!
2. **Memory (virtual memory):** हरेक program लाई **नक्कली address** दिइन्छ। CPU भित्रको **MMU** chip ले **page table** हेरेर साँचो RAM मा अनुवाद गर्छ। त्यसैले एउटा program ले अर्कोको memory छुन सक्दैन। Page = ४ KB।
3. **Device drivers:** hardware चलाउने, program लाई एउटै सजिलो तरिका दिने।
4. **System calls:** program ले kernel सँग माग्ने तरिका (🍽️ waiter जस्तै): `open`, `read`, `write`, `close`
   - नयाँ program सुरु हुँदा: **fork** (आफ्नो copy बनाउने) → **exec** (त्यो copy अर्को program बन्ने)। *"copy, then become"*
   - `strace` ले यो साँच्चै देखायो।
   - Pseudodevice: `/dev/null` (कालो प्वाल, लेखेको सबै हराउँछ), `/dev/urandom` (random नम्बर)

### Users
- Kernel ले नाम होइन, **नम्बर (UID)** बुझ्छ। **root = UID 0** (superuser)।
- **Group** = धेरै user ले फाइल बाँड्ने तरिका। **GID** = group को नम्बर।
- **Least privilege:** हरेक service (जस्तै `netdata`) लाई आफ्नै सानो user दिने। Hack भए पनि **क्षति सानो** हुन्छ।

---

## 📗 Chapter 2: Basic Commands

### Lesson 1 ✅: Shell र आधारभूत command
- **Shell** = command चलाउने program। हामी **bash** चलाउँछौं। Ubuntu मा `/bin/sh` → **dash**।
- किताबमा `$` = साधारण user, `#` = root (sudo)। `$` र `#` आफैं टाइप नगर्ने!
- **३ stream:** `0` stdin (keyboard), `1` stdout (screen), `2` stderr (error)
- `Ctrl-D` = अब input छैन (EOF) · `Ctrl-C` = तुरुन्तै रोक्ने

| Command | काम |
|---|---|
| `ls -l` | फाइलको विवरण सहित list |
| `cp a b` | copy (दुवै फाइल रहन्छन्) |
| `mv a b` | सार्ने **वा नाम फेर्ने** ⭐ |
| `touch f` | खाली फाइल बनाउने / समय अपडेट गर्ने |
| `rm f` | मेटाउने। ⚠️ recycle bin छैन! |
| `rmdir d` | खाली folder मेटाउने |
| `rm -r d` | folder र भित्रको सबै मेटाउने ⚠️ |

- Pi को समय **Sydney (AEDT)**, VM को **UTC**। एउटै क्षण, ११ घण्टा फरक।

### Lesson 2 ✅: Folder मा घुम्ने + शक्तिशाली tools
- **Absolute path** = `/` बाट सुरु (`/usr/lib`), जहाँबाट पनि काम गर्छ।
- **Relative path** = अहिले जहाँ छु त्यहाँबाट। `..` = माथि, `.` = यहीं, `~` = home।
- `cd` shell भित्रै बनेको (built-in) हुन्छ, किनभने child process ले parent को folder फेर्न सक्दैन (fork!)।
- **Wildcard:** `*` = जे पनि, `?` = एउटा अक्षर। ⭐ **Shell ले command चल्नुअघि नै expand गर्छ।**
- **grep** = फाइलभित्र शब्द खोज्ने (🌾 छलनी): `-i` ठूलो/सानो अक्षर बिर्सने, `-v` उल्टो, `-c` गन्ती, `-w` पूरा शब्द
- `less` (पाना-पाना पढ्ने, `q` ले बाहिर), `pwd`, `diff`, `file`, `find`, `head`, `tail -f` (log live हेर्ने ⭐), `sort`
- `cd ..` मा **space चाहिन्छ**!

### Lesson 3 🔁: Shell को settings, editor, help (भोलि ३ प्रश्न दोहोर्याउने)
- **Dot files** (`.bashrc`, `.ssh`) = लुकेका settings फाइल। `ls -a` ले देखाउँछ।
- **Shell variable** (`FRUIT=mango`) = आफ्नो मात्र। **`export`** पछि **environment variable** बन्छ र बच्चा process लाई पुग्छ (🧬 DNA जस्तै)।
- **PATH** = command खोज्ने folder को list। बायाँबाट दायाँ खोज्छ, पहिलो भेटिएको चलाउँछ (🛒 पसल-पसल)।
- **Keyboard:** `Ctrl-A` सुरु, `Ctrl-E` अन्त्य, `Ctrl-W` शब्द मेटाउने, `Ctrl-U` सबै मेटाउने, `Ctrl-Y` फेरि टाँस्ने, `Tab` autocomplete
- **vi:** `i` = टाइप गर्न सुरु, `Esc` = रोक्ने, `:wq` = save + बाहिर, `:q!` = save नगरी बाहिर। vi मा `Ctrl-C` ले काम गर्दैन!
- **man:** `man ls` = manual। `man 5 passwd` = `/etc/passwd` **फाइल** को manual (section 5)। `man passwd` = command को (section 1)।

---

## 🔐 मैले भेटेका साँचो कुरा
- **VM मा आक्रमण:** internet का bot हरूले **८४७ पटक** login गर्न खोजे (`admin`, `user`, `test` नाम राखेर)। तर VM ले **SSH key मात्र** स्वीकार्छ, त्यसैले कोही भित्र पसेनन् ✅
- **INC-001:** VM मा पुरानो `tv-webhook` service ले बारम्बार crash गर्दैछ (५,५००+ पटक restart)। Program मेटिएको तर service अझै चालू। Chapter 6 मा ठीक गर्ने।
- **INC-002:** Pi नोभेम्बर ७ राति २१:४२ मा अचानक बन्द भयो (shutdown सन्देश बिना) → बिजुली वा USB drive को समस्या हुन सक्छ।
- Pi मा **घडी (RTC) छैन**: boot हुँदा July 28 सोच्छ, internet ले मिलाउँछ।
- VM को `adminrabin` account मा फोन नम्बर छ जुन सबैले पढ्न सक्छन्। पछि हटाउने।

---

## 🏗️ मेरो Project: trading-infra-lab
- GitHub: **github.com/rbkunwar/trading-infra-lab**
- **Infrastructure** मा केन्द्रित: trading होइन, trading चल्ने platform बनाउने, सुरक्षित राख्ने, छिटो बनाउने, निगरानी गर्ने।
- VM = "production server", Pi = "ops / monitoring box"
- **८ स्तम्भ:** security, storage, services, **time sync** ⏱️, **low latency** ⚡, networking, monitoring, automation/incidents
- हरेक chapter सकेपछि त्यस chapter सँग मिल्ने काम थप्ने। Chapter 2 पछिको काम: `feed` user, `traders` group, permission।
- नियम: trading होइन, API key होइन, पैसा होइन। IP र गोप्य कुरा GitHub मा नराख्ने।

---

## 📦 Git (अब म आफैं commit गर्छु!)
```
cd ~/linux-project     → सही folder मा जाने
git status             → के बदलियो?
git add <फाइल>         → 📦 बाकसमा राख्ने
git commit -m "सन्देश"  → 📦 बाकस बन्द गरेर लेबल लगाउने
git push               → 📬 GitHub मा पठाउने
```
- मेरा दुई repo: **linux-homelab** (notes) र **trading-infra-lab** (project)
- पहिलो commit: `Add git cheat-sheet` 🎉

---

## 🔜 भोलि
1. Lesson 3 का ३ प्रश्न दोहोर्याउने: `export`, `PATH`, `man 5 passwd`
2. **Lesson 4:** `>` `>>` `|` `2>` (redirection र pipe)। `2>/dev/null` को साँचो अर्थ!

```
Chapter 1  ██████████  6/6  ✅
Chapter 2  ██░░░░░░░░  5/21
```
