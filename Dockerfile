# Use the latest official Ubuntu image as the base for the container
FROM ubuntu:latest

# Define build-time arguments (These values are provided during the build process)
# Email for HoneyGain
ARG HONEYGAIN_EMAIL
# Password for HoneyGain
ARG HONEYGAIN_PASSWORD
# Email for Pawns
ARG PAWNS_EMAIL
# Password for Pawns
ARG PAWNS_PASSWORD
# Name of the client (used as device name)
ARG CLIENT_NAME

# Set the build-time arguments as environment variables (These will be available at runtime)
# Set HoneyGain email as an environment variable
ENV HONEYGAIN_EMAIL=$HONEYGAIN_EMAIL
# Set HoneyGain password as an environment variable
ENV HONEYGAIN_PASSWORD=$HONEYGAIN_PASSWORD
# Set Pawns email as an environment variable
ENV PAWNS_EMAIL=$PAWNS_EMAIL
# Set Pawns password as an environment variable
ENV PAWNS_PASSWORD=$PAWNS_PASSWORD
# Set client name as an environment variable
ENV CLIENT_NAME=$CLIENT_NAME
# Prevent interactive prompts during package installations (useful for non-interactive Docker builds)
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list.
RUN apt-get update

# Install OpenVPN, iproute2, iptables, curl
# RUN apt-get install openvpn iproute2 iptables curl -y

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
COPY build/honeygain /usr/local/bin/honeygain
COPY build/libhg.so.2.0.0 /usr/lib
COPY build/libmsquic.so.2 /usr/lib

# Make the Honeygain binary executable
RUN chmod +x /usr/local/bin/honeygain

# Start OpenVPN and sleep indefinitely to keep the container running
# CMD ["openvpn --config /etc/openvpn/client/nordvpn.ovpn --daemon --log /var/log/openvpn.log"]
# Run commands when the container starts
CMD honeygain -tou-accept -email "$HONEYGAIN_EMAIL" -pass "$HONEYGAIN_PASSWORD" -device "$CLIENT_NAME" & pawns-cli -email "$PAWNS_EMAIL" -password "$PAWNS_PASSWORD" -device-name "$CLIENT_NAME" -device-id "$CLIENT_NAME" -accept-tos & sleep infinity

# Build the Docker Image
# docker build -f Dockerfile --build-arg HONEYGAIN_EMAIL="example@example.com" --build-arg HONEYGAIN_PASSWORD="securepass" --build-arg PAWNS_EMAIL="example@example.com" --build-arg PAWNS_PASSWORD="securepass" --build-arg CLIENT_NAME="bandwidth-manager-node-1" -t bandwidth-manager-node-1 .

# Run the Container
# docker run --dns 1.1.1.1 --dns 1.0.0.1 -d --name bandwidth-manager-node-1 --cap-add=NET_ADMIN --device /dev/net/tun bandwidth-manager-node-1
