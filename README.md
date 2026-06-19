# TravelMemory – MERN Stack Deployment on AWS

> Deploying a MERN (MongoDB, Express, React, Node.js) application on AWS using **Terraform** for infrastructure and **Ansible** for configuration management.

---

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Part 1: Terraform](#part-1-infrastructure-setup-with-terraform)
- [Part 2: Ansible](#part-2-configuration-and-deployment-with-ansible)
- [Application Access](#application-access)
- [Security](#security)
- [Teardown](#teardown)

---

## 🏗️ Architecture

```
Internet
    │
    ▼
[Elastic IP]
    │
[Web Server EC2 - Public Subnet 10.0.1.0/24]
    ├── NGINX (port 80)
    ├── React Frontend (port 3000)
    └── Express Backend (port 3001)
            │ MongoDB (port 27017)
            ▼
[DB Server EC2 - Private Subnet 10.0.2.0/24]
    └── MongoDB 7.0
```

> 📸 _Add screenshot: AWS VPC Architecture_

---

## ✅ Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.3.0
- Ansible >= 2.14
- SSH key pair at `~/.ssh/travelmemory`

```bash
ssh-keygen -t ed25519 -f ~/.ssh/travelmemory -C "travelmemory"
curl ifconfig.me   # get your IP for trusted_ip
```

---

## 📁 Project Structure

```
TravelMemory/
├── terraform/
│   ├── main.tf          # VPC, subnets, IGW, NAT Gateway
│   ├── ec2.tf           # EC2 instances, key pair, Elastic IP
│   ├── security.tf      # Security groups, IAM role
│   ├── backend.tf       # S3 backend, DynamoDB lock
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── terraform.tfvars # Your values (git-ignored)
└── ansible/
    ├── ansible.cfg      # Ansible configuration
    ├── inventory.ini    # Host definitions
    ├── site.yml         # Master playbook
    ├── group_vars/
    │   └── all.yml      # Vault-encrypted secrets
    └── roles/
        ├── webserver/   # Node.js, NGINX, React, PM2
        └── database/    # MongoDB 7.0 + auth
```

---

## Part 1: Infrastructure Setup with Terraform

### Step 1 – Configure AWS CLI

```bash
aws configure
```

> 📸 _Add screenshot: AWS CLI configuration_

### Step 2 – Initialize Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
terraform init
```

> 📸 _Add screenshot: terraform init output_

### Step 3 – S3 Backend + DynamoDB Locking

```bash
terraform apply -target=aws_dynamodb_table.terraform_lock
terraform init -migrate-state
```

> 📸 _Add screenshot: S3 bucket with state file_
> 📸 _Add screenshot: DynamoDB lock table_

### Step 4 – Plan and Apply

```bash
terraform plan
terraform apply
```

> 📸 _Add screenshot: terraform apply complete_

### Step 5 – Outputs

```bash
terraform output
# web_server_public_ip = "100.49.217.31"
# db_server_private_ip = "10.0.2.116"
```

> 📸 _Add screenshot: terraform outputs_
> 📸 _Add screenshot: EC2 instances in AWS Console_
> 📸 _Add screenshot: Security groups_

### Resources Created

| Resource | Details |
|---|---|
| VPC | 10.0.0.0/16 |
| Public Subnet | 10.0.1.0/24 |
| Private Subnet | 10.0.2.0/24 |
| Internet Gateway | Attached to VPC |
| NAT Gateway | Public subnet |
| Web EC2 | t3.small, Ubuntu, public |
| DB EC2 | t3.small, Ubuntu, private |
| Elastic IP | Web server |
| Web SG | Ports 22, 80, 443, 3000, 3001 |
| DB SG | Port 27017 from web SG only |
| IAM Role | SSM + CloudWatch |
| S3 Backend | Encrypted state storage |
| DynamoDB | State locking |

---

## Part 2: Configuration and Deployment with Ansible

### Step 1 – Update Inventory

```ini
[webservers]
web ansible_host=100.49.217.31 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/travelmemory

[databases]
db ansible_host=10.0.2.116 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/travelmemory ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=ubuntu@100.49.217.31'

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```

### Step 2 – Vault Secrets

```bash
echo 'your_vault_password' > ~/.vault_pass
chmod 600 ~/.vault_pass

ansible-vault encrypt_string 'tmuser' --name 'mongo_app_user' --vault-password-file ~/.vault_pass --encrypt-vault-id default
ansible-vault encrypt_string 'StrongPassword123' --name 'mongo_app_password' --vault-password-file ~/.vault_pass --encrypt-vault-id default
ansible-vault encrypt_string 'AdminPassword123' --name 'mongo_admin_password' --vault-password-file ~/.vault_pass --encrypt-vault-id default
```

### Step 3 – Test Connectivity

```bash
ansible all -m ping
# web | SUCCESS => { "ping": "pong" }
# db  | SUCCESS => { "ping": "pong" }
```

> 📸 _Add screenshot: ansible all -m ping success_

### Step 4 – Run Playbook

```bash
ansible-playbook site.yml
```

> 📸 _Add screenshot: playbook running_
> 📸 _Add screenshot: PLAY RECAP all ok_

---

## 🌐 Application Access

| Service | URL |
|---|---|
| Frontend | `http://100.49.217.31` |
| Frontend direct | `http://100.49.217.31:3000` |
| Backend API | `http://100.49.217.31:3001` |
| Trips endpoint | `http://100.49.217.31:3001/trip` |

```bash
curl http://100.49.217.31:3001/trip
```

> 📸 _Add screenshot: TravelMemory app in browser_
> 📸 _Add screenshot: /trip API response_
> 📸 _Add screenshot: pm2 list showing both processes_
> 📸 _Add screenshot: systemctl status mongod_

---

## 🔒 Security

| Measure | Implementation |
|---|---|
| MongoDB private subnet | No public IP |
| DB SSH access | ProxyJump via web server only |
| SSH key-pair only | PasswordAuthentication no |
| Root login disabled | PermitRootLogin no |
| MongoDB auth | Role-based, authorization enabled |
| Secrets | Ansible Vault encrypted |
| State | S3 AES256 encrypted |
| State lock | DynamoDB LockID |
| IAM | Least privilege (SSM + CloudWatch) |

---

## 🗑️ Teardown

```bash
cd terraform/
terraform destroy
```

> ⚠️ Deletes all AWS resources. S3 bucket has `prevent_destroy = true` — delete manually if needed.

---

## 👤 Author

**Avinash Sain**  
GitHub: https://github.com/Avinashsain  
Repository: https://github.com/Avinashsain/TravelMemory