server              = true
node_name           = "$NODE_NAME"
datacenter          = "dc1"
data_dir            = "/var/consul/data"
bind_addr           = "0.0.0.0"
client_addr         = "0.0.0.0"
advertise_addr      = "$ADVERTISE_ADDR"
bootstrap_expect    = 3
retry_join          = "$RETRY_JOINS"

ui_config {
    enabled = true
}

log_level           = "DEBUG"
enable_syslog       = true