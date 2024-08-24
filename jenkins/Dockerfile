FROM jenkins/jenkins:lts
 
# Switch to root user to install dependencies
USER root
 
# Install Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh
 
# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
 
# Add jenkins user to docker group
RUN usermod -aG docker jenkins
 
# Switch back to jenkins user
USER jenkins
