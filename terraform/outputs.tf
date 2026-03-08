# 📤 TERRAFORM OUTPUTS FILE
#
# Outputs are like the "results" screen after Terraform finishes building your infrastructure.
# After running `terraform apply`, these values get printed to your terminal.
#
# 💡 Analogy: Think of outputs like the receipt you get after shopping —
# they tell you exactly what was created and where to find it!

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUT: The public IP address of our web server
# After Terraform runs, this tells you how to reach your server!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
output "web_server_public_ip" {
  description = "The public IP address of the web server — use this to visit your site!"
  # We're reading the public_ip attribute FROM the aws_instance resource we created in main.tf.
  value = aws_instance.web_server.public_ip
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUT: The server's unique ID in AWS
# Useful if you ever need to look up or manage this server in the AWS console.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
output "web_server_id" {
  description = "The unique AWS instance ID of the web server (e.g. i-0abc1234567)"
  value       = aws_instance.web_server.id
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUT: The name of the S3 storage bucket
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
output "storage_bucket_name" {
  description = "The name of the S3 bucket created for app storage"
  value       = aws_s3_bucket.app_storage.bucket
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OUTPUT: Which environment was deployed
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
output "environment" {
  description = "The environment this infrastructure was deployed to (dev/staging/prod)"
  value       = var.environment
}
