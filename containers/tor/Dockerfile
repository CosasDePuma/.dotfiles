# How to run
# docker run -d --rm --name tor -p 9050:9050 cosasdepuma/tor

# Base image
FROM alpine:latest

# Update the repository
RUN apk --update upgrade
# Install tor
RUN apk add --no-cache tor
# Configure tor
RUN echo "SocksPort 0.0.0.0:9050" > /etc/torrc

# Expose the service
EXPOSE 9050

# Set the extrypoint
ENTRYPOINT ["tor","-f","/etc/torrc"]
