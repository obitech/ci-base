FROM ubuntu:bionic

ENV TERRAFORM_VERSION=0.12.20
ENV GO_VERSION=1.13.7

# Install general packages
RUN apt-get update && apt-get install -y \
    make busybox wget git curl software-properties-common rsync jq

# Install Python
RUN apt-get install -y \
    python3 python3-pip python python-pip && \
    pip install --upgrade pip && python --version && pip --version && \
    pip3 install --upgrade pip && python3 --version && pip3 --version

# Install Go
RUN wget -q "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    go version && \
    go get -u golang.org/x/lint/golint

ENV GOPATH /go
ENV GOBIN $GOPATH/bin
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Install Terraform
RUN wget -qO- "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" | \
    busybox unzip - -d /usr/local/bin && \
	chmod +x /usr/local/bin/terraform && \
    terraform version

# Install Ansible
RUN pip3 install ansible && ansible --version

# Install cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/... && \
    cfssl version

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/
