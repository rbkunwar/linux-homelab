# Trading scenario drills: नेपालीमा व्याख्या (2026-11-11)

> यो file `nepali` branch मा मात्र commit गर्ने। English version: `scenarios/trading-scenarios-ch01-ch02.md` (branch `real-world-scenarios`)।

⚠️ **पहिले एउटा कुरा:** मैले यी सबै **माथिको pane (Raspberry Pi)** मा चलाएँ। Prompt `rabindrakunwar@rabindrakunwar` थियो। VM को prompt `ubuntu@bot-vnic` हुन्छ। त्यसैले VM मा अझै गर्न बाँकी छ (तलको pane)।

## Drill 1: Feed जमेको (frozen feed)
- `( while ... ) > feed.log &` → नक्कली price feed: हरेक सेकेन्ड `TICK BTCUSD` लेख्छ, background मा चल्छ।
- `F=$!` → भर्खर चलाएको background job को PID (1101740) लाई `F` भन्ने variable मा राख्यौँ।
- `kill -STOP $F` → process लाई **pause** गर्यौँ। Shell ले `Stopped` भन्यो।
- `ps` मा **STAT = T** → T = stopped। Process अझै जिउँदो छ, तर काम गर्दैन।
- CMD मा `-bash` किन? `( )` ले shell को **fork** (copy) बनाउँछ, नयाँ program `exec` गर्दैन। त्यसैले नाम parent कै रहन्छ (`-` = login shell)। Chapter 1 को fork/exec!
- `tail -1 feed.log; date +%T` → अन्तिम tick **23:32:59**, अहिलेको समय **23:33:45**: **46 सेकेन्ड** data आएन! Trading company मा market खुल्ने बेला यो ठूलो incident हो।
- `kill -CONT $F` → फेरि चलाइयो, tick फेरि आउन थाले (23:34:00, :01, :02)।
- `kill $F` → TERM, shell ले `Terminated` भन्यो।
- **सिकाइ:** process "जिउँदो" हुनु ≠ service "ठीक" हुनु। Data ताजा छ कि छैन, त्यो पनि हेर्नुपर्छ।

## Drill 3: Stale lock (पुरानो lock file)
- `sleep 600 & echo $! > gateway.lock` → नक्कली gateway चलायौँ, उसको PID lock file मा लेख्यौँ।
- `kill -9 $(cat gateway.lock)` → `$( )` भित्रको command पहिले चल्छ (PID निकाल्छ), अनि kill -9। Shell ले `Killed` भन्यो।
- -9 ले cleanup गर्न दिँदैन → **lock file बाँकी रह्यो**।
- `set -C; echo $$ > gateway.lock` → नयाँ gateway सुरु गर्न खोज्यो → `cannot overwrite existing file`। यही हो "gateway start हुँदैन" भन्ने समस्या।
- `ps -p $(cat gateway.lock) || echo "stale lock..."` → ps ले header मात्र देखायो (त्यो PID अब छैन), त्यसैले `||` पछिको echo चल्यो।
- `rm gateway.lock` → पुरानो lock हटायौँ।
- **सिकाइ:** पहिले `kill` (TERM), त्यसपछि मात्र `kill -9`।

## Drill 6: /dev/null ले error लुकाउँछ
- पहिलो पटक `>/dev/null 2>&1` → केही देखिएन, तर `exit=1` (fail भयो!)।
- दोस्रो पटक बिना /dev/null → साँचो error देखियो: `No such file or directory`।
- **सिकाइ:** महत्त्वपूर्ण job (backup) को error कहिल्यै /dev/null मा नफाल्नू। Log file मा पठाउनू।

## Drill 7: UAT कि PROD? (export)
- `FEED_ENV=prod` मात्र गर्दा → child ले `[]` (खाली) देख्यो।
- `export FEED_ENV` पछि → child ले `[prod]` देख्यो।
- तपाईंले `export` दुई पटक टाइप गर्नुभयो, केही बिग्रँदैन।
- **सिकाइ:** shell variable ≠ environment variable। `export` नगरे child process (तपाईंको program) ले देख्दैन।

## Drill 8: हातले चल्छ, cron मा चल्दैन
- `PATH=$PATH:~/drills/bin` → आफ्नो folder PATH मा थप्यौँ → `risk_report` चल्यो।
- `env -i PATH=/usr/bin:/bin ...` → cron जस्तै सानो PATH → `command not found`।
- पूरा path (`~/drills/bin/risk_report`) दिँदा → चल्यो।
- **सिकाइ:** script र cron मा सधैँ **full path** लेख्नू।

## Drill 9: कुन symbol reject भइरहेको छ?
- `grep REJECT` → REJECT भएका line मात्र।
- `cut -d' ' -f3,4` → space ले छुट्याएर 3rd र 4th शब्द (symbol र कारण)।
- `sort | uniq -c | sort -rn` → गन्ने, धेरैदेखि थोरै।
- नतिजा: **ETHUSD price_band ३ पटक**, SOLUSD max_qty १ पटक → समस्या मुख्यतः ETHUSD मा।

## Cleanup
- `jobs` → खाली = केही पनि background मा बाँकी छैन ✅
- `cd ~ && rm -r ~/drills` → practice folder मेटायौँ ✅
