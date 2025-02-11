#!/usr/bin/env bash

imds_token=$( curl -Ss -H "X-aws-ec2-metadata-token-ttl-seconds: 30" -XPUT 169.254.169.254/latest/api/token )
instance_id=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/instance-id )
local_ipv4=$( curl -Ss -H "X-aws-ec2-metadata-token: $imds_token" 169.254.169.254/latest/meta-data/local-ipv4 )

hostname client-$(hostname)

# install package

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install -y consul-enterprise=${consul_version}+ent awscli jq

echo "Configuring system time"
timedatectl set-timezone UTC

# /opt/consul/tls should be readable by all users of the system
mkdir /opt/consul/tls
chmod 0755 /opt/consul/tls

printf "%s" "${ca_cert}" > /opt/consul/tls/consul-ca.pem

aws s3 cp "s3://${s3_bucket_consul_license}/${consul_license_name}" /opt/consul/consul.hclic

# consul.hclic should be readable by the consul group only
chown root:consul /opt/consul/consul.hclic
chmod 0640 /opt/consul/consul.hclic

gossip_encryption_key=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn_gossip} --region ${region} --output text --query SecretString)

acl_tokens=$(aws secretsmanager get-secret-value --secret-id ${secrets_manager_arn_acl_token} --region ${region} --output text --query SecretString)

cat << EOF > /etc/consul.d/consul.hcl
ca_file                = "/opt/consul/tls/consul-ca.pem"
data_dir               = "/opt/consul/data"
encrypt                = "$gossip_encryption_key"
license_path           = "/opt/consul/consul.hclic"
server                 = false
verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true
datacenter             = "dc1"
primary_datacenter     = "dc1"
bind_addr              = "0.0.0.0"

retry_join = [
  "provider=aws region=${region} tag_key=${name}-consul tag_value=cluster",
]

acl {
  enabled                  = true
  default_policy           = "deny"
  enable_token_persistence = true
  tokens {
    $acl_tokens 
  }
}

auto_encrypt {
  tls = true
}

connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}

ports {
  https = 8501
  grpc  = 8502
}

ui_config {
  enabled = false 
}

EOF

# consul.hcl should be readable by the consul group only
chown root:root /etc/consul.d
chown root:consul /etc/consul.d/consul.hcl
chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul

echo "Setup Consul profile"
cat <<PROFILE | sudo tee /etc/profile.d/consul.sh
export CONSUL_HTTP_ADDR="https://127.0.0.1:8501"
export CONSUL_GRPC_ADDR="https://127.0.0.1:8502"
PROFILE
