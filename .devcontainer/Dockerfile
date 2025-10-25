FROM mcr.microsoft.com/devcontainers/python:3.11
RUN apt-get update && apt-get install -y default-jre
COPY ../requirements.txt /tmp/pip-tmp/
RUN pip3 install --no-cache-dir -r /tmp/pip-tmp/requirements.txt