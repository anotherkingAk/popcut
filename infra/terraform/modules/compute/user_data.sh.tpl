#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export ENVIRONMENT="${environment}"
export REGION="${region}"
export DB_CREDENTIALS_SECRET_ARN="${db_credentials_secret_arn}"
export JWT_SECRET_ARN="${jwt_secret_arn}"

dnf update -y
dnf install -y amazon-cloudwatch-agent jq postgresql16 git

systemctl enable amazon-cloudwatch-agent

mkdir -p /opt/popcut
mkdir -p /opt/popcut/config

cat > /opt/popcut/config/cw-agent.json << 'CWEOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "PopCut",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_user", "rename": "CPU_USER", "unit": "Percent"},
          {"name": "cpu_usage_system", "rename": "CPU_SYSTEM", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED_PERCENT", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED_PERCENT", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/popcut/${environment}/syslog",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/opt/popcut/logs/*.log",
            "log_group_name": "/popcut/${environment}/application",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CWEOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/popcut/config/cw-agent.json \
  -s

cat > /opt/popcut/config/env.sh << 'ENVEOF'
#!/bin/bash
export ENVIRONMENT="${environment}"
export REGION="${region}"

get_secret() {
  aws secretsmanager get-secret-value \
    --secret-id "$1" \
    --region "$REGION" \
    --query SecretString \
    --output text
}

export DB_CREDENTIALS=$(get_secret "${DB_CREDENTIALS_SECRET_ARN}")
export DB_USERNAME=$(echo "$DB_CREDENTIALS" | jq -r .username)
export DB_PASSWORD=$(echo "$DB_CREDENTIALS" | jq -r .password)
export JWT_SECRET=$(get_secret "${JWT_SECRET_ARN}")

get_ssm_param() {
  aws ssm get-parameter \
    --name "/popcut/${ENVIRONMENT}/$1" \
    --region "$REGION" \
    --with-decryption \
    --query Parameter.Value \
    --output text 2>/dev/null || echo ""
}

export DB_HOST=$(get_ssm_param "database/host")
export DB_PORT=$(get_ssm_param "database/port")
export DB_NAME=$(get_ssm_param "database/name")
export REDIS_HOST=$(get_ssm_param "redis/host")
export REDIS_PORT=$(get_ssm_param "redis/port")
ENVEOF

chmod +x /opt/popcut/config/env.sh

echo "User data script completed successfully"
