#!/bin/bash

CURR_DIR=$(basename $(pwd))

start=$(date +%s)

PID=$(cat crx-quickstart/conf/cq.pid 2>/dev/null)
if [ "$PID" ]; then
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        STOP_CODE=$?
        echo "killing process ${PID} ..."
        i=1
        sp="⠋⠙⠚⠒⠂⠂⠒⠲⠴⠦⠖⠒⠐⠐⠒⠓⠋"
        while $(kill -0 $PID 2>/dev/null); do
			# Get the terminal width
            term_width=$(tput cols)
            # Reserve some space for the spinner and a space (e.g., 10 characters)
            max_log_length=$((term_width - 2))
            # Get the last line of the log file and truncate it to fit the terminal width
            log_line=$(tail -n 1 crx-quickstart/logs/error.log | cut -c -$max_log_length)
			# Calculate the padding needed
            padding_length=$((term_width - ${#log_line} - 2)) # 2 for spinner and space
            padding=$(printf '%*s' "$padding_length")
            printf "\r${sp:i++%${#sp}:1} $log_line$padding"
            sleep 0.5
        done
        end=$(date +%s)
        log_line="process ${PID} was killed in $(($end-$start)) seconds"
		padding_length=$((term_width - ${#log_line})) # 2 for spinner and space
		padding=$(printf '%*s' "$padding_length")
        printf "\r$log_line$padding\n"
		osascript -e "display notification \"AEM server ($PID) has been stopped\" with title \"AEM Server\""
    else
        echo "process ${PID} not running"
        STOP_CODE=4
    fi
else
    echo "cq.pid not found"
    STOP_CODE=4
fi

