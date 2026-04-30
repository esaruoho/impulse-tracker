@echo off
REM Build IT.EXE and every sound + network driver.
REM Run from the repo root in DOS / DOSBox-X with TASM 4.1 / TLINK 3.x / MAKE 4.0 on PATH.
REM
REM IMPORTANT: Use TLINK 3.x (1990 Borland), not TLINK 7.1 (1996).
REM TLINK 7.1 rejects driver objects with "Fatal: No program entry point".
REM TLINK 3.x links both IT.EXE *and* every driver without modification.

echo === Building IT.EXE ===
make -f MAKEFILE.MAK > MAKE.LOG
type MAKE.LOG

echo === Building sound drivers (writes ..\DRV_SND.LOG) ===
cd SoundDrivers
call BUILDALL.BAT
cd ..

echo === Building network drivers (writes ..\DRV_NET.LOG) ===
cd Network
call BUILDALL.BAT
cd ..

echo BUILDALL_DONE > BUILDALL.STAT
echo === All done. See MAKE.LOG, DRV_SND.LOG, DRV_NET.LOG ===
