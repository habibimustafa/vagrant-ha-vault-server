// global policy
path "kv-v2/data/app/*" {
  capabilities = ["create", "update"]
}

// custom policy
path "kv-v2/data/app/env" {
  capabilities = ["read"]
}
