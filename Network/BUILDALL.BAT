@echo off
REM Build every network driver by running each M*.BAT in this directory.
REM Run from inside Network\ in DOS / DOSBox-X with TASM, TLINK on PATH.
REM Per-iteration redirect — see SoundDrivers/BUILDALL.BAT for rationale.

echo === Building all Impulse Tracker network drivers === > ..\DRV_NET.LOG
for %%B in (M*.BAT) do call %%B >> ..\DRV_NET.LOG
echo === Done. Drivers copied to parent directory. === >> ..\DRV_NET.LOG
