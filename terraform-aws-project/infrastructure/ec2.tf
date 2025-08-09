# ec2.tf

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_jenkins_cidrs
    description = "Jenkins UI"
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_grafana_cidrs
    description = "Grafana UI"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}

# IAM role for Jenkins EC2 instance
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "jenkins_role"
  }
}

# Attach necessary policies to Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_eks_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# IAM instance profile for Jenkins EC2
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.jenkins_role.name
}

# EC2 instance for Jenkins server
resource "aws_instance" "jenkins" {
  ami                    = var.jenkins_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "Jenkins Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "Starting user data script"
    sudo apt update -y
    sudo apt install -y docker.io awscli

    # Install kubectl
    curl -o kubectl https://amazon-eks.s3.${var.aws_region}.amazonaws.com/${var.cluster_version}/2021-07-05/bin/linux/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    sudo chmod 666 /var/run/docker.sock

    # Pull and run Jenkins Docker container
    sudo docker pull jenkins/jenkins:lts

    sudo docker run -d \
      --name jenkins \
      --restart=on-failure \
      --group-add $(getent group docker | cut -d: -f3) \
      -p 8080:8080 \
      -p 50000:50000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v jenkins_home:/var/jenkins_home \
      jenkins/jenkins:lts

    echo "User data script completed"
  EOF
}

# EC2 instance for Grafana server
resource "aws_instance" "grafana" {
  ami                    = var.grafana_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "Grafana Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data-grafana.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "Starting Grafana installation"
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https software-properties-common wget

    # Install Grafana
    wget -q -O /usr/share/keyrings/grafana.key https://packages.grafana.com/gpg.key
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    sudo apt-get update -y
    sudo apt-get install -y grafana
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server

    echo "Grafana installation completed"
  EOF
}
