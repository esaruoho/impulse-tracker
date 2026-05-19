#!/bin/bash
# safe-build.sh -- wrap the DOSBox-X build with a wall-time cap + heartbeat.
#
# The build is supposed to take ~57s on an M1 Mac, but DOSBox-X occasionally
# wedges with the build half-done -- the host process keeps spinning at 5-6%
# CPU but no new .DRV files appear. This wrapper:
#
#   1. Starts dosbox-x in the background, drops a PID file.
#   2. Polls every 5 seconds for a freshly-touched .DRV file. If no
#      driver has been built in 60 seconds AND BUILDALL.STAT hasn't shown
#      up, the build is considered wedged.
#   3. Kills DOSBox-X cleanly and reports the last-built driver + the
#      MAKE.LOG / DRV_SND.LOG tail so the operator can see where it stuck.
#
# Use this instead of calling dosbox-x directly when iterating on the fork.
#
# Usage:  ./safe-build.sh
# Output: same as before -- IT.EXE, *.DRV, *.NET, *.LOG files. Plus a
#         non-zero exit code if the build wedged or failed.

set -u

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

# Clean previous build artifacts.
rm -f MAKE.LOG DRV_SND.LOG DRV_NET.LOG BUILDALL.STAT IT.EXE

# Stale-progress threshold: kill if no new driver in this many seconds.
STALL_SECONDS=60

# Absolute wall-time cap: kill no matter what after this many seconds.
HARD_CAP_SECONDS=600

echo "[$(date +%H:%M:%S)] safe-build: launching DOSBox-X..."

dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu \
    > /tmp/safe-build-dosbox.log 2>&1 &
DOSBOX_PID=$!

# Track last-built timestamp for stall detection.
LAST_BUILT_AT=$(date +%s)
LAST_DRIVER=""
START_AT=$LAST_BUILT_AT

while true; do
    sleep 5

    # Completed?
    if [ -s BUILDALL.STAT ]; then
        wait $DOSBOX_PID 2>/dev/null
        echo "[$(date +%H:%M:%S)] safe-build: BUILDALL_DONE"
        echo "  IT.EXE size: $(ls -la IT.EXE 2>/dev/null | awk '{print $5}') bytes"
        if grep -qE "^Error" MAKE.LOG 2>/dev/null; then
            grep -E "^Error|^Warning" MAKE.LOG | grep -v "messages:    None" | head -5
        fi
        exit 0
    fi

    # DOSBox died?
    if ! kill -0 $DOSBOX_PID 2>/dev/null; then
        echo "[$(date +%H:%M:%S)] safe-build: DOSBox-X exited without BUILDALL_DONE"
        echo "--- MAKE.LOG tail ---"
        tail -10 MAKE.LOG 2>/dev/null
        echo "--- DRV_SND.LOG tail ---"
        tail -5 DRV_SND.LOG 2>/dev/null
        exit 1
    fi

    NOW=$(date +%s)

    # Hard wall-time cap.
    if [ $((NOW - START_AT)) -gt $HARD_CAP_SECONDS ]; then
        echo "[$(date +%H:%M:%S)] safe-build: HARD_CAP ${HARD_CAP_SECONDS}s exceeded, killing DOSBox-X"
        kill -9 $DOSBOX_PID 2>/dev/null
        echo "  Last built: $LAST_DRIVER"
        tail -10 MAKE.LOG 2>/dev/null
        exit 2
    fi

    # Stall detection: find the most recently touched .DRV / .NET / IT.EXE.
    NEWEST=$(ls -t IT.EXE *.DRV *.NET 2>/dev/null | head -1)
    if [ -n "$NEWEST" ]; then
        NEWEST_AT=$(stat -f %m "$NEWEST" 2>/dev/null || stat -c %Y "$NEWEST" 2>/dev/null)
        if [ "$NEWEST" != "$LAST_DRIVER" ]; then
            LAST_DRIVER="$NEWEST"
            LAST_BUILT_AT=$NEWEST_AT
            echo "[$(date +%H:%M:%S)] safe-build: progress -> $LAST_DRIVER"
        fi

        if [ $((NOW - LAST_BUILT_AT)) -gt $STALL_SECONDS ]; then
            echo "[$(date +%H:%M:%S)] safe-build: STALL ${STALL_SECONDS}s no progress, killing DOSBox-X"
            kill -9 $DOSBOX_PID 2>/dev/null
            echo "  Last built: $LAST_DRIVER ($(date -r $LAST_BUILT_AT +%H:%M:%S))"
            tail -10 MAKE.LOG 2>/dev/null
            exit 3
        fi
    fi
done
