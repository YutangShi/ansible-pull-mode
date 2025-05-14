#!/bin/bash
HOSTNAME=$(hostname)

# Collect CPU metrics
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
# Collect Memory metrics
mem_total=$(free | grep Mem | awk '{print $2}')
mem_used=$(free | grep Mem | awk '{print $3}')
# Collect Temperature metrics
temp=$(sensors | grep 'temp1' | awk '{print $2}' | tr -d '+°C' | head -n 1)
# Collect Disk usage metrics
disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
# Collect audio status only if pactl is available
if command -v pactl >/dev/null 2>&1; then
   audio_status=$(pactl list short sinks | wc -l)
else
   audio_status=0
fi


# Collect max dBFS volume using ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
   max_db=$(ffmpeg -f pulse -i default -af volumedetect -t 5 -f null /dev/null 2>&1 \
     | grep max_volume \
     | sed -E 's/.*max_volume:\s*([-0-9.]+)\s*dB.*/\1/')
else
   max_db=-100  # default fallback value
fi


# Use cat to send metrics to curl directly in Prometheus format
cat <<EOF | curl -iv --data-binary @- https://pushgateway.productplus.cc/metrics/job/heartbeat/instance/$HOSTNAME
# HELP cpu_usage CPU usage percentage
# TYPE cpu_usage gauge
cpu_usage{host="$HOSTNAME"} $cpu_usage


# HELP memory_total Total memory available in bytes
# TYPE memory_total gauge
memory_total_bytes{host="$HOSTNAME"} $mem_total


# HELP memory_used Memory used in bytes
# TYPE memory_used gauge
memory_used_bytes{host="$HOSTNAME"} $mem_used


# HELP temperature CPU temperature in Celsius
# TYPE temperature gauge
cpu_temperature_celsius{host="$HOSTNAME"} $temp


# HELP disk_usage Disk usage percentage
# TYPE disk_usage gauge
disk_usage_percentage{host="$HOSTNAME"} $disk_usage


# HELP audio_sinks Number of audio sinks available
# TYPE audio_sinks gauge
audio_sinks{host="$HOSTNAME"} $audio_status


# HELP audio_max_dbfs Maximum audio dBFS level from ffmpeg volumedetect
# TYPE audio_max_dbfs gauge
audio_max_dbfs{host="$HOSTNAME"} $max_db
EOF
