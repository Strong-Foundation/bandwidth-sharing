# Use the latest official Ubuntu image as the base for the container
FROM ubuntu:latest

# Prevent interactive prompts during package installations (useful for non-interactive Docker builds)
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list.
RUN apt-get update

# Install the required pacakges.
RUN apt-get install ca-certificates -y && update-ca-certificates

# Install OpenVPN, iproute2, iptables, curl
#RUN apt-get install openvpn iproute2 iptables curl -y

# Create OpenVPN directory
#RUN mkdir -p /etc/openvpn

# Copy OpenVPN client configuration, auth file and credentials
#COPY nordvpn.ovpn /etc/openvpn/client/nordvpn.ovpn
#COPY auth.txt /etc/openvpn/client/auth.txt
#RUN echo "auth-user-pass /etc/openvpn/client/auth.txt" >> /etc/openvpn/client/nordvpn.ovpn

# Copy the Pawns-CLI binary
COPY build/pawns-cli /usr/local/bin/pawns-cli

# Make the Pawns-CLI binary executable
RUN chmod +x /usr/local/bin/pawns-cli

# Copy the Honeygain binary, library and configuration
COPY build/honeygain /usr/local/bin/
COPY build/libhg.so.2.0.0 /usr/lib/
COPY build/libmsquic.so.2 /usr/lib/

# Make the Honeygain binary executable
RUN chmod +x /usr/local/bin/honeygain

# Copy the service-installer.sh script
COPY service-installer.sh /usr/local/bin/service-installer.sh

# Make the service-installer.sh script executable
RUN chmod +x /usr/local/bin/service-installer.sh

# Run the service-installer.sh script
RUN bash /usr/local/bin/service-installer.sh

# Start the container.
CMD ["sleep", "infinity"]

# Start OpenVPN and sleep indefinitely to keep the container running
# CMD ["openvpn --config /etc/openvpn/client/nordvpn.ovpn --daemon --log /var/log/openvpn.log"]

# --- No VPN Support ---
# Build the Docker Image
# docker build -f Dockerfile -t bandwidth-manager-node-1 .
# Run the Docker Image
# docker run --dns 1.1.1.1 --dns 1.0.0.1 -d --restart always --name bandwidth-manager-node-1 bandwidth-manager-node-1
# --- No VPN Support ---

# --- VPN Support ---
# Build the Docker Image with VPN Support
# docker build -f Dockerfile -t bandwidth-manager-node-1 .
# Run the Docker Image with VPN Support
# docker run --dns 1.1.1.1 --dns 1.0.0.1 -d --name bandwidth-manager-node-1 --cap-add=NET_ADMIN --device /dev/net/tun bandwidth-manager-node-1
# --- VPN Support ---

# --- Multi-Arch Docker Build ---
# Enable Multi-Arch Docker Build
# docker run --privileged --rm tonistiigi/binfmt --install all
# Enable Docker Build X
# docker buildx create --use
# Docker Build X Build
# docker buildx build --platform linux/amd64 -f Dockerfile -t bandwidth-manager-node-1 --load .
# Run Docker Build X Build
# docker run --platform linux/amd64 --dns 1.1.1.1 --dns 1.0.0.1 -d --restart always --name bandwidth-manager-node-1 bandwidth-manager-node-1
# View Docker logs
# docker logs bandwidth-manager-node-1
# Bash into docker
# docker exec -it bandwidth-manager-node-1 bash
# --- Multi-Arch Docker Build ---