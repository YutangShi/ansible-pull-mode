#!/bin/bash
# filepath: /opt/docker/ansible-pull-mode/entrypoint.sh

# 建立 crontab 檔案
echo "# Ansible Pull 每小時執行" > /etc/crontab.d
echo "0 * * * * /usr/bin/ansible-pull -U https://github.com/YutangShi/ansible-pull-mode.git >> /log/ansible-pull.log 2>&1" >> /etc/crontab.d
echo "# Metrics 腳本每 5 分鐘執行" >> /etc/crontab.d
echo "*/5 * * * * /metrics.sh" >> /etc/crontab.d

# 使用 Supercronic 執行 crontab
exec /usr/local/bin/supercronic /etc/crontab.d
