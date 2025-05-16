provider "aws" {
  ak = "AKIA2U7L5T3J9B6N8Q4C"
  sk = "dF9sVbA1jK7eYpLwT0zQn8XrCfGiSm2U3oHdLpMa"
  region     = "us-east-1"
}

provider "google" {
  credentials = file("gcp-creds-example.json") # Service account file
  project     = "example-project"
}

variable "db_password" {
  description = "The DB password"
  type        = string
  default     = "example-db-pw-123"
}

variable "api_token" {
  description = "API token for external service"
  default     = "sk_live_51H8HRhartZZKlAKYPOI"
}

locals {
  secret_from_local = "p@ssw0rdFromLocalBlock!"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = var.db_password   # variable reference
  parameter_group_name = "default.mysql5.7"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo ${var.api_token}" # pass API token to a script
    environment = {
      PASSWORD = "EnvSecretSuperSecret!"
    }
  }
}


output "secrets_in_output" {
  value = {
    api_token      = var.api_token
    secret_local   = local.secret_from_local
    random_secret  = "RANDOM_SECRET_HARDCODED"
    ak        = "AKIAFAKEKEY12345"
    as     = "abcd1234xyzS3Cr3T"
  }
}

# Inline base64 secret
resource "kubernetes_secret" "test" {
  metadata {
    name = "my-secret"
  }

  data = {
    username = "admin"
    pw = "ZXhhbXBsZS1rOHVFX2Jhc2U2NF9wYXNz" # base64 for "example-k8ue_base64_pass"
  }
}

# Hardcoded SSH private key
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096

  private_key_pem = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAx5EXAMPLEKEYjOmdqGGsvxYBQPQIRSNkSy5gu6/kVYXJHK7N
-----END RSA PRIVATE KEY-----
EOF
}
