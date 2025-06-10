# Use an official RunPod base image
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel-ubuntu22.04

# Environment variables
ENV PYTHONUNBUFFERED=1 

# Modes can be: pod, serverless
ARG MODE_TO_RUN=pod
ENV MODE_TO_RUN=$MODE_TO_RUN

# Set up the working directory
ARG WORKSPACE_DIR=/app
ENV WORKSPACE_DIR=${WORKSPACE_DIR}
WORKDIR $WORKSPACE_DIR

# Install dependencies in a single RUN command to reduce layers
# Clean up in the same layer to reduce image size
RUN apt-get update --yes --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    software-properties-common \
    gpg-agent \
    build-essential \
    apt-utils \
    ca-certificates \
    curl && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt-get update --yes --quiet && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends

# Create and activate a Python virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir \
    asyncio \
    requests \
    runpod

# Install requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
# Remove Runpod's copy of start.sh and replace it with our own
RUN rm ../start.sh

# COPY EVERYTHING INTO THE CONTAINER
COPY handler.py $WORKSPACE_DIR/handler.py
COPY start.sh $WORKSPACE_DIR/start.sh

# Make sure start.sh is executable
RUN chmod +x start.sh

# Make sure that the start.sh is in the path
RUN ls -la $WORKSPACE_DIR/start.sh

# depot build -t justinrunpod/pod-server-base:1.0 . --push --platform linux/amd64
CMD $WORKSPACE_DIR/start.sh

