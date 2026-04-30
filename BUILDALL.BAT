@echo off
REM Build IT.EXE and every sound + network driver.
REM Run from the repo root in DOS / DOSBox-X with TASM, TLINK, MAKE on PATH.

echo === Building IT.EXE ===
make -f MAKEFILE.MAK > MAKE.LOG
type MAKE.LOG

echo === Building sound drivers ===
cd SoundDrivers
call BUILDALL.BAT > ..\DRV_SND.LOG
cd ..

echo === Building network drivers ===
cd Network
call BUILDALL.BAT > ..\DRV_NET.LOG
cd ..

echo BUILDALL_DONE > BUILDALL.STAT
echo === All done. See MAKE.LOG, DRV_SND.LOG, DRV_NET.LOG ===
