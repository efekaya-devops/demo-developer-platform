#!/usr/bin/env bash
# Start/stop the hosted demo (play.efekaya.io) to make the AWS credits last.
#
# A stopped instance bills only its EBS volume and its Elastic IP, not compute
# - which is the whole point: running it around the clock burns the $100 in
# about six weeks, while office hours stretch it across roughly five months.
#
#   ./demo-platform.sh start|stop|status
set -euo pipefail

INSTANCE_ID=i-03188bd6bc0c084f0
REGION=eu-north-1
URL=https://play.efekaya.io

aws_ec2() { aws ec2 "$@" --region "$REGION"; }

state() {
  aws_ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].State.Name' --output text
}

case "${1:-status}" in
  start)
    [ "$(state)" = "running" ] && { echo "already running - $URL"; exit 0; }
    aws_ec2 start-instances --instance-ids "$INSTANCE_ID" >/dev/null
    echo "starting..."
    aws_ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    # kind + backstage come back on their own (docker restart policy + systemd),
    # but the cluster needs a moment before the portal answers
    echo -n "waiting for the portal"
    for _ in $(seq 1 40); do
      code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$URL" || true)
      [ "$code" = "200" ] && { echo " - up: $URL"; exit 0; }
      echo -n "."; sleep 15
    done
    echo " - still not answering; check: ssh ubuntu@$URL 'systemctl status backstage'"
    ;;
  stop)
    [ "$(state)" = "stopped" ] && { echo "already stopped"; exit 0; }
    aws_ec2 stop-instances --instance-ids "$INSTANCE_ID" >/dev/null
    echo "stopping - compute billing ends once it reaches 'stopped'"
    ;;
  status)
    echo "instance: $(state)"
    echo "portal:   $(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "$URL" || echo unreachable)"
    ;;
  *) echo "usage: $0 start|stop|status" >&2; exit 1 ;;
esac
