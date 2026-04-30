@echo off
REM Build every sound driver by running each M*.BAT in this directory.
REM Run from inside SoundDrivers\ in DOS / DOSBox-X with TASM, TLINK on PATH.
REM Each M*.BAT does: tasm -> tlink -> execom -> copy IT*.DRV ..
REM EXECOM.COM is shipped in this directory.

echo === Building all Impulse Tracker sound drivers ===
for %%B in (M*.BAT) do (
    echo --- %%B ---
    call %%B
)
echo === Done. Drivers copied to parent directory. ===
