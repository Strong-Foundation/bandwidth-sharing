FROM ubuntu:latest

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenVPN and required packages
RUN apt-get update &&  \
    apt-get install openvpn iproute2 iptables curl -y

# Create OpenVPN directory
RUN mkdir -p /etc/openvpn

# Copy OpenVPN client configuration, auth file and credentials
COPY nordvpn.ovpn /etc/openvpn/client/nordvpn.ovpn
COPY auth.txt /etc/openvpn/client/auth.txt
RUN echo "auth-user-pass /etc/openvpn/client/auth.txt" >> /etc/openvpn/client/nordvpn.ovpn

# Copy the Pawns-CLI binary
COPY build/pawns-cli /usr/local/bin/pawns-cli

# Make the Pawns-CLI binary executable
RUN chmod +x /usr/local/bin/pawns-cli

# Run the Pawns-CLI
# pawns-cli -email=example@example.com -password=example#123 -device-name=bandwidth-manager-node-1 -device-id=bandwidth-manager-node-1 -accept-tos

# Copy the Honeygain binary, library and configuration
COPY build/honeygain /usr/local/bin/honeygain
COPY build/libhg.so.2.0.0 /usr/lib
COPY build/libmsquic.so.2 /usr/lib

# Make the Honeygain binary executable
RUN chmod +x /usr/local/bin/honeygain

# Run the Honeygain
# honeygain -tou-accept -email example@example.com -pass example#123 -device bandwidth-manager-node-1

# Start OpenVPN and sleep indefinitely to keep the container running
# CMD ["openvpn --config /etc/openvpn/client/nordvpn.ovpn --daemon --log /var/log/openvpn.log && sleep infinity"]
CMD ["sleep", "infinity"]

# Build the Docker Image
# docker build -f Dockerfile -t bandwidth-manager-node-1 .

# Run the Container
# docker run --dns 1.1.1.1 --dns 1.0.0.1 -d --name bandwidth-manager-node-1 --cap-add=NET_ADMIN --device /dev/net/tun bandwidth-manager-node-1

# Access the Running Container
# docker exec -it bandwidth-manager-node-1 bash

# Check OpenVPN Logs
# docker exec -it bandwidth-manager-node-1 cat /var/log/openvpn.log
