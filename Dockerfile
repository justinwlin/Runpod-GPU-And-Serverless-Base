# Use an official and specific version tag if possible, instead of 'latest'
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel-ubuntu22.04

# Environment variables
ENV PYTHONUNBUFFERED=1 

# Modes can be: pod, serverless
ARG MODE_TO_RUN=pod
ENV MODE_TO_RUN=$MODE_TO_RUN

ARG CONCURRENCY_MODIFIER=1
ENV CONCURRENCY_MODIFIER=$CONCURRENCY_MODIFIER

# Set up the working directory
WORKDIR /app

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
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-venv \
    python3.11-lib2to3 \
    python3.11-gdbm \
    python3.11-tk && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --auto python3

# Install pip manually
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.11 get-pip.py && \
    rm get-pip.py

# Create and activate a Python virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install Python packages
# Install Python packages in a single RUN instruction
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    OhMyRunPod \
    asyncio \
    requests \
    runpod==1.6.2 \
    langchain==0.0.259 \
    "openllm[vllm]"

# Install requirements.txt
COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
    
# Remove Runpod's copy of start.sh and replace it with our own
RUN rm ../start.sh

# COPY EVERYTHING INTO THE CONTAINER
COPY . .

RUN chmod +x start.sh

# depot build -t justinwlin/serverlessllm:1.0 . --push --platform linux/amd64
CMD ["/app/start.sh"]