@echo off
REM Build every sound driver by running each M*.BAT in this directory.
REM Run from inside SoundDrivers\ in DOS / DOSBox-X with TASM, TLINK on PATH.
REM Each M*.BAT does: tasm -> tlink -> execom -> copy IT*.DRV ..
REM EXECOM.COM is shipped in this directory.
REM
REM Per-iteration redirect into ..\DRV_SND.LOG: COMMAND.COM doesn't
REM propagate parent redirects into nested CALLs, so the parent
REM BUILDALL.BAT must NOT redirect us; we manage our own log.

echo === Building all Impulse Tracker sound drivers === > ..\DRV_SND.LOG
for %%B in (M*.BAT) do call %%B >> ..\DRV_SND.LOG
echo === Done. Drivers copied to parent directory. === >> ..\DRV_SND.LOG
