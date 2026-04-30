@echo off
REM Build every network driver by running each M*.BAT in this directory.
REM Run from inside Network\ in DOS / DOSBox-X with TASM, TLINK on PATH.

echo === Building all Impulse Tracker network drivers ===
for %%B in (M*.BAT) do (
    echo --- %%B ---
    call %%B
)
echo === Done. Drivers copied to parent directory. ===
