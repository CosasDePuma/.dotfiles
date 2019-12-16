# How to run
# docker run -it --rm --name wpscan cosasdepuma/wpscan --help

# Base image
FROM ruby

# Install WPScan
RUN gem install wpscan
RUN wpscan --update

# Set up the entrypoint
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]
