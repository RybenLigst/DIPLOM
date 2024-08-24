#!/bin/bash
 
# Ensure Docker group exists
groupadd -f docker 2>/dev/null

# Add user to Docker group (if not already added)
if ! id -nG | grep -q docker; then
  read -p "Add current user to Docker group? (y/N): " add_to_docker
  if [[ "$add_to_docker" =~ ^[Yy]$ ]]; then
    sudo usermod -aG docker "$USER"
    sudo service docker restart
  fi
fi
 
# Set permissions for Docker socket
echo "Setting permissions for Docker socket..."
sudo chmod 666 /var/run/docker.sock
 
# Build Jenkins Docker image
echo "Building Jenkins Docker image..."
docker build -t jenkins-docker .
 
# Remove existing Jenkins container if it exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^jenkins\$"; then
  echo "Removing existing Jenkins container..."
  docker rm -f jenkins
fi
 
# Run Jenkins Docker container on port 8080
echo "Running Jenkins Docker container..."
docker run -d \
  --name jenkins \
  --group-add $(getent group docker | cut -d: -f3) \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins-docker
 
# Wait for Jenkins to initialize and display initial password
echo "Waiting for Jenkins to initialize..."
sleep 60
echo "Initial Jenkins admin password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
 
# Generate SSH key inside Jenkins Docker container
echo "Generating SSH key inside Jenkins Docker container..."
docker exec jenkins bash -c 'mkdir -p /var/jenkins_home/.ssh/'
docker exec -u jenkins jenkins ssh-keygen -t ed25519 -f /var/jenkins_home/.ssh/id_ed25519 -C "vasiliprevakky@gmail.com" -q -N ""
 
# Display Jenkins generated SSH public and private keys
echo "Jenkins SSH public key:"
docker exec jenkins cat /var/jenkins_home/.ssh/id_ed25519.pub
echo "Jenkins SSH private key (**WARNING!: Do not share this**):"
docker exec jenkins cat /var/jenkins_home/.ssh/id_ed25519
 
# Add GitHub to known hosts for Jenkins container
echo "Adding GitHub to known hosts for Jenkins container..."
docker exec jenkins bash -c 'ssh-keyscan -t ed25519 github.com >> /var/jenkins_home/.ssh/known_hosts'
 
# Verify known hosts
echo "Verifying known hosts:"
docker exec jenkins cat /var/jenkins_home/.ssh/known_hosts
