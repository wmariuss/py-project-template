FROM python:3.6
LABEL maintainer "Marius Stanca <me@marius.xyz>"


# Fix locale
RUN echo "LC_ALL=en_US.UTF-8" > /etc/default/locale && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale

# Add executable
ADD dist/py-project-template.pex /bin/py-project-template

ENTRYPOINT ["/bin/py-project-template"]
