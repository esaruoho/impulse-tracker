# Deploy Impulse Tracker (fork) → netdrive / ITNU2026 (XP / DOS workspace)

The canonical build + deploy + debug runbook for the fork. The SKILL.md "Deploy to
netdrive/ITNU2026" section summarises this; this file is the full reference.

**What gets deployed:** the **BUILD** — `IT.EXE` + every sound/network driver
(`*.DRV`, `*.NET`), ~1.3 MB — plus the **perfect `IT.CFG`**. **Not** the source tree.

**Where it goes:** `C:\netdrive\ITNU2026` on XP. `netdrive` (`C:\netdrive`) is the
folder the **DOS PC maps as `E:`** (`E: → \\DROIDI\NETDRIVE`), so anything dropped
here is reachable from XP, the DOS PC, AND the Mac (mounted at `/Volumes/netdrive`).

---

## Connection reference (the workspace fleet)
- **XP box:** `192.168.32.50` · hostname `droidi` · Windows XP Pro SP3
- **Login:** user `fleet` · password `Lackluster1!` (admin we made for remote access; `esaruoho` console user untouched)
- **DOS PC:** `192.168.200.1`, on XP's *second* NIC (`192.168.200.2`); maps `E: → \\DROIDI\NETDRIVE`
- **SMB shares on XP:** `netdrive` (=`C:\netdrive`), `CDrive` (=`C:\`), `DDrive`, `EDrive`, `SharedDocs`
- **Shell:** `ssh XP32Bit` (interactive only — Bitvise's non-interactive exec is flaky)
- Password in an `smb://` URL must be URL-encoded: `Lackluster1!` → `Lackluster1%21`

---

## 1. Build (on the Mac, via DOSBox-X)

Full build (IT.EXE + all drivers, ~60 s):
```bash
cd ~/work/impulse-tracker
./safe-build.sh           # success line: "safe-build: BUILDALL_DONE" + IT.EXE size
```
Prereq once: `brew install dosbox-x`.

**Fast IT.EXE-only rebuild** (when only `IT*.ASM` changed — what the agent uses to
verify a code fix in ~25 s; no driver rebuild). Conf mounts repo as `C:`,
`tools-local/` as `T:`, runs `make`:
```bash
cd ~/work/impulse-tracker
cat > /tmp/itbuild.conf <<'EOF'
[dosbox]
machine=svga_s3
memsize=64
[cpu]
cycles=max
[dos]
ver=6.22
xms=true
ems=true
lfn=true
[autoexec]
mount c .
mount t ./tools-local
set PATH=T:\;%PATH%
c:
del IT.EXE
make -f MAKEFILE.MAK > MAKE.LOG
exit
EOF
dosbox-x -conf /tmp/itbuild.conf -fastlaunch -exit -nogui -nomenu
# verify: grep -A2 "IT_MUSIC.asm" MAKE.LOG  → "Error messages: None"; ls -la IT.EXE
```
A clean link = `IT.EXE` exists with a fresh timestamp (it was `del`'d first). **Build
verifies assemble+link only — it does NOT runtime-test.** The render reboot/hang only
reproduce on the real DOS hardware with live audio; grade such fixes `@build-verified`,
not `@runtime-verified`.

## 2. Mount the XP network drive
```bash
open "smb://fleet:Lackluster1%21@192.168.32.50/netdrive"   # mounts at /Volumes/netdrive
```
(Already mounted? skip. Force a clean remount: `umount -f /Volumes/netdrive` first.)

## 3. Deploy to `netdrive\ITNU2026`

Minimal (just the fixed IT.EXE — drivers unchanged), what the agent uses:
```bash
cd ~/work/impulse-tracker
DST=/Volumes/netdrive/ITNU2026
/bin/cp -p "$DST/IT.EXE" "$DST/IT_PREV.EXE"     # keep a rollback (rename back if worse)
/bin/rm -f "$DST/IT.EXE"; /bin/cp IT.EXE "$DST/IT.EXE"
/bin/cp -f IT.CFG.perfect "$DST/IT.CFG"         # the PERFECT settings (see below)
/usr/bin/cmp IT.EXE "$DST/IT.EXE" && echo deployed-ok
```
`cp` on the Mac is interactive-aliased — use `/bin/cp` / `/bin/rm` to avoid the prompt.

Full drop (after a `safe-build.sh`, including all drivers):
```bash
rm -rf /tmp/itbuild && mkdir -p /tmp/itbuild
find . -maxdepth 2 \( -iname 'IT.EXE' -o -iname '*.DRV' -o -iname '*.NET' \) \
     -mmin -15 -not -path './build-*' -exec cp {} /tmp/itbuild/ \;
mkdir -p /Volumes/netdrive/ITNU2026
/bin/cp -f /tmp/itbuild/* /Volumes/netdrive/ITNU2026/
/bin/cp -f IT.CFG.perfect /Volumes/netdrive/ITNU2026/IT.CFG
```
Verify: `ls /Volumes/netdrive/ITNU2026/IT.EXE /Volumes/netdrive/ITNU2026/IT.CFG && du -sh /Volumes/netdrive/ITNU2026` (~1.3 MB, ~45 files incl. IT.CFG).

## 4. The perfect `IT.CFG` (boot straight into a reproducible state)

`IT.CFG.perfect` is the versioned canonical config — keyboard, MIDI, drivers, and the
fork's `ForkExt` block. Its directory rows currently point at:
- Module dir `C:\MODULES` · Sample dir `C:\SAMPLES`
- **Quicksave dir `E:\ITNU2026`** ← renders AND the debug log land here (see §6)
- `E:\2LOGIC` (cross-machine Logic handoff)

Because Quicksave = `E:\ITNU2026`, every render writes into the same folder the Mac
sees at `/Volumes/netdrive/ITNU2026` — so renders and `CTRLOLOG.TXT` round-trip with
no extra plumbing.

**Keeping it perfect:** IT.EXE rewrites `IT.CFG` at runtime, so when you tune settings
*on XP/DOS* they live in `C:\netdrive\ITNU2026\IT.CFG`. Capture them back as canonical:
```bash
/bin/cp -f /Volumes/netdrive/ITNU2026/IT.CFG ~/work/impulse-tracker/IT.CFG.perfect
git -C ~/work/impulse-tracker add IT.CFG.perfect && git -C ~/work/impulse-tracker commit -m "IT.CFG.perfect: capture tuned settings"
```
Don't blindly overwrite a freshly-tuned target `IT.CFG` with an older repo copy — pull first if in doubt.

## 5. Run it
- **On XP:** `C:\netdrive\ITNU2026\IT.EXE`
- **On the DOS PC:** `E:\ITNU2026\IT.EXE` (E: = the mapped network drive)

## 6. Back-and-forth debug logging (CTRLOLOG.TXT)

The WAV-render path writes a persistent, rotating log to **`CTRLOLOG.TXT` in the render
directory** = the Quicksave folder = `E:\ITNU2026`. On the Mac:
```bash
cat /Volumes/netdrive/ITNU2026/CTRLOLOG.TXT      # (older history rotates to CTRLOLOG.OLD at 32 KB)
```
Each render gesture (Ctrl-O, right-arrow / Shift-right at the order-list edge, Ctrl-G,
Shift-G) appends lines. Two are the fork's **state snapshots** (`WAV_LogState`):
```
E pat=HHHH pm=HHHH sm=HHHH mm=HHHH o0=HHHH se=HHHH it=FFFF   <- render INPUTS (enter)
START file=<name> bytes=0000 size=0000
X pat=HHHH pm=HHHH sm=HHHH mm=HHHH o0=HHHH se=HHHH it=HHHH   <- render OUTCOME (sync exit)
OK   file=<name>.WAV bytes=HHHH size=HHHH
```
Field meanings (all hex):
- `pat` pattern being rendered · `pm` PlayMode snapshot at enter (1=pattern, 2=song)
- `sm` WAV_SongMode · `mm` WAV_MultiMode · `o0` **OrderList[0]** (`00FF` = empty order list)
- `se` StopEndOfPlaySection (`0001` = one-pass terminator armed — the hang fix)
- `it` sync-loop iterations remaining at exit: **`0000` = hit the 100000 cap = HUNG**;
  a large value = terminated after one pass (healthy). On the `E` line `it=FFFF` (not-yet-run).

So after a repro: read `CTRLOLOG.TXT` here. A healthy single-pattern render shows
`se=0001` and `it` non-zero on the `X` line plus an `OK file=...` line. If you ever see
`it=0000`, the render didn't terminate; `o0=00FF` flags the empty-order-list case.
Row-0 **VRAM markers** (the letters across the top during a render) are the live
companion when there's no file to read — see SKILL.md "VRAM Debug Markers".

---

## Notes & gotchas
- Driver copies may also live in old `build-YYYY-MM-DD-*` snapshot folders — the
  `-not -path './build-*'` + `-mmin -15` filter avoids stale ones. If a deploy looks
  short, drop `-mmin -15` and re-run after a fresh `safe-build.sh`.
- C: has ~120 GB free — disk space is not a concern.
- The DOS PC reaches XP by the NetBIOS name `DROIDI`, resolved via a static
  `LMHOSTS`/`HOSTS` entry on the DOS PC (`192.168.200.2 DROIDI`). Do not remove it or
  the `E:` mapping breaks (Error 53).
- Always keep `IT_PREV.EXE` as the one-step rollback for the last good binary.
