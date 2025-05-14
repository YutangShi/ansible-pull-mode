#!/bin/bash
# filepath: /opt/docker/ansible-pull-mode/entrypoint.sh

mkdir -p /etc/crontab.d

# 建立 crontab 檔案
echo "# Ansible Pull 每小時執行" > /etc/crontab.d/ansible-cron
echo "*/5 * * * * /usr/bin/ansible-pull -U https://github.com/YutangShi/ansible-pull-mode.git  >> /var/log/ansible-pull.log 2>&1" >> /etc/crontab.d/ansible-cron
echo "# Metrics 腳本每 5 分鐘執行" >> /etc/crontab.d/ansible-cron
echo "*/5 * * * * /metrics.sh" >> /etc/crontab.d/ansible-cron

/usr/local/bin/supercronic /etc/crontab.d/ansible-cron
