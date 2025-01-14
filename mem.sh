#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Check if a command was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [args...]"
    exit 1
fi

# Create an isolated cgroup path
CGROUP_PATH="/sys/fs/cgroup/monitor_$$"

# Create new cgroup
mkdir -p "$CGROUP_PATH"

# Set maximum memory to "max" (unlimited) instead of 0
echo max > "$CGROUP_PATH/memory.max"

# Add ourselves to the cgroup before executing the command
echo $$ > "$CGROUP_PATH/cgroup.procs"

# Run the command
"$@"
CMD_EXIT_CODE=$?

# Get memory usage
CURRENT_MEM=$(cat "$CGROUP_PATH/memory.current" 2>/dev/null || echo 0)
PEAK_MEM=$(cat "$CGROUP_PATH/memory.peak" 2>/dev/null || echo 0)

# Use the larger value
if [ "$CURRENT_MEM" -gt "$PEAK_MEM" ]; then
    MAX_MEM=$CURRENT_MEM
else
    MAX_MEM=$PEAK_MEM
fi

MAX_MEM_MB=$(echo "scale=2; $MAX_MEM / 1024 / 1024" | bc)

echo "Maximum memory usage: $MAX_MEM_MB MB"

# Move back to root cgroup
echo $$ > /sys/fs/cgroup/cgroup.procs

# Clean up with retries
for i in $(seq 1 3); do
    if rmdir "$CGROUP_PATH" 2>/dev/null; then
        break
    fi
    # Move any remaining processes to root
    [ -f "$CGROUP_PATH/cgroup.procs" ] && \
        cat "$CGROUP_PATH/cgroup.procs" | while read pid; do
            echo $pid > /sys/fs/cgroup/cgroup.procs 2>/dev/null
        done
    sleep 0.1
done

exit $CMD_EXIT_CODE
