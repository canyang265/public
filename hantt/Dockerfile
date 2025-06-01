FROM alpine:latest AS builder

RUN apk add --no-cache \
    curl \
    wget \
    unzip \
    jq \
    ca-certificates

RUN TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name | sed 's/v//') && \
    echo "Downloading Terraform - $TERRAFORM_VERSION" && \
    mkdir -p /opt/terraform && \
    cd /opt/terraform && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    chmod 755 terraform

RUN PACKER_VERSION=$(curl -s https://api.github.com/repos/hashicorp/packer/releases/latest | jq -r .tag_name | sed 's/v//') && \
    echo "Downloading Packer version: $PACKER_VERSION" && \
    mkdir -p /opt/packer && \
    cd /opt/packer && \
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod 755 packer

FROM alpine:latest

LABEL maintainer="Matthew Yang" \
      description="Image for practice" \
      version="latest"

RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    openssh-client \
    git \
    bash \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/cache/apk/*

RUN ln -sf python3 /usr/bin/python

RUN pip3 install --no-cache-dir --break-system-packages --upgrade pip && \
    pip3 install --no-cache-dir --break-system-packages \
    awscli \
    ansible \
    boto3 \
    botocore \
    requests \
    pyyaml \
    paramiko \
    cryptography \
    && rm -rf /root/.cache/pip/*

COPY --from=builder --chmod=755 /opt/terraform/terraform /usr/local/bin/terraform
COPY --from=builder --chmod=755 /opt/packer/packer /usr/local/bin/packer

WORKDIR /practice

RUN addgroup -g 1000 practice && \
    adduser -D -s /bin/bash -u 1000 -G practice practice && \
    chown -R practice:practice /practice

USER practice

ENV PATH="/home/practice/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    ANSIBLE_HOST_KEY_CHECKING=False

RUN python --version && \
    aws --version && \
    terraform version && \
    ansible --version && \
    packer version

CMD ["/bin/bash"]
