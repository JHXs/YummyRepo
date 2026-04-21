#!/bin/bash
set -e

# 日志文件路径
LOGFILE="/home/hansel/logs/sync-yum.log"

# 记录开始时间及输出到日志文件
{
    echo "========================================="
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sync started"

    cd /home/hansel/ssd/syncthing/ITProject/YummyRepo
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running fetch.sh"
    bash scripts/fetch.sh

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running createrepo_c --update packages"
    createrepo_c --update packages

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sync finished successfully"
    echo "========================================="
} >> "$LOGFILE" 2>&1
