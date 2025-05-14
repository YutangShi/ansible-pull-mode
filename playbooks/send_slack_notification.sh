#!/bin/bash
# filepath: /opt/docker/ansible-pull-mode/playbooks/send_slack_notification.sh

# 使用方式：./send_slack_notification.sh "成功|失敗" "主機名稱"

STATUS="$1"
HOSTNAME="$2"
WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL"  # 請替換為您的 Slack Webhook URL

if [ "$STATUS" == "成功" ]; then
    COLOR="good"
    TITLE="Ansible Pull 執行成功 ✅"
else
    COLOR="danger"
    TITLE="Ansible Pull 執行失敗 ❌"
fi

PAYLOAD="{
    \"attachments\": [
        {
            \"color\": \"$COLOR\",
            \"title\": \"$TITLE\",
            \"text\": \"主機: $HOSTNAME\n時間: $(date '+%Y-%m-%d %H:%M:%S')\n詳細日誌: /log/ansible-pull.log\",
            \"footer\": \"Ansible Pull 自動化部署\",
            \"ts\": $(date +%s)
        }
    ]
}"

curl -s -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$WEBHOOK_URL"
