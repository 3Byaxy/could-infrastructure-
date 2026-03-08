# 🐧 We start FROM the official Ubuntu 22.04 image.
# Think of this like choosing a blank computer to work with!
FROM ubuntu:22.04

# 🔕 This stops Ubuntu from asking us questions during installation.
ENV DEBIAN_FRONTEND=noninteractive

# 📦 Install basic tools that almost every developer needs.
# RUN means "run this command while building the container."
RUN apt-get update && apt-get install -y \
    curl \       
    wget \       
    git \        
    unzip \      
    python3 \    
    python3-pip \
    sudo \       
    ca-certificates \
    gnupg \      
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# 👤 Create a non-root user called "vscode" for safer development.
# It's like having a regular user account instead of always being the administrator!
RUN useradd -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 👤 Switch to our new "vscode" user.
USER vscode

# 📁 Set the working directory inside the container.
WORKDIR /workspaces/could-infrastructure-
