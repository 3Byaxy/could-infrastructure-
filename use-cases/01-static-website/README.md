# Use Case 1: Deploying a Simple Static Website

Deploy a static HTML website to **AWS S3** using Terraform, or run it locally with **Docker Compose** and Nginx.

---

## 📁 Directory Structure

```
01-static-website/
├── terraform/
│   ├── main.tf          # S3 bucket + website hosting configuration
│   ├── variables.tf     # Input variables
│   └── outputs.tf       # Output values (website URL)
├── website/
│   └── index.html       # Sample static website
├── docker-compose.yml   # Local Nginx server for testing
└── README.md
```

---

## Option A: Deploy to AWS S3 with Terraform

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5 installed

### Steps

1. **Navigate to the terraform directory:**
   ```bash
   cd terraform
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan -var="bucket_name=my-static-site-$(date +%s)"
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply -var="bucket_name=my-static-site-$(date +%s)"
   ```

5. **Upload the website files:**
   ```bash
   aws s3 sync ../website/ s3://YOUR_BUCKET_NAME/
   ```

6. **Visit your website:**
   The website URL will be shown in the Terraform output as `website_url`.

7. **Clean up resources:**
   ```bash
   terraform destroy
   ```

---

## Option B: Run Locally with Docker Compose

### Prerequisites
- Docker >= 24.0
- Docker Compose >= 2.0

### Steps

1. **Start the local web server:**
   ```bash
   docker compose up -d
   ```

2. **Open in browser:**
   Navigate to [http://localhost:8080](http://localhost:8080)

3. **Stop the server:**
   ```bash
   docker compose down
   ```

---

## What You'll Learn

- Provisioning an S3 bucket with Terraform
- Enabling S3 static website hosting
- Setting bucket policies for public read access
- Running Nginx locally with Docker Compose
- Using Terraform `outputs` to retrieve resource URLs
