FROM alpine:3.9

ENV TERRAFORM 0.11.13
ENV ATLANTIS 0.7.1
ENV PACKER 1.4.0
ENV ANSIBLE 2.7.10
ENV AZ 2.0.63

RUN apk add -U python3 curl bash jq && \
    apk add --virtual=build gcc python3-dev musl-dev libffi-dev openssl-dev make unzip && \
    python3 -m venv ansible-env && \
    /ansible-env/bin/pip3 install ansible[azure]==${ANSIBLE} && \
    python3 -m venv azure-env && \
    /azure-env/bin/pip3 install --upgrade requests && \
    /azure-env/bin/pip3 install azure-cli==${AZ} && \
    curl -sSL "https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip" -o /tmp/terraform_linux_amd64.zip && \
    unzip /tmp/terraform_linux_amd64.zip -d /usr/bin/ && \
    curl -sSL https://releases.hashicorp.com/packer/${PACKER}/packer_${PACKER}_linux_amd64.zip -o /tmp/packer_linux_amd64.zip && \
    unzip /tmp/packer_linux_amd64.zip -d /usr/bin/ && \
    curl -sSL https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS}/atlantis_linux_amd64.zip -o /tmp/atlantis_linux_amd64.zip && \
    unzip /tmp/atlantis_linux_amd64.zip -d /usr/bin/ && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apk del --purge build && \
    rm -rf /tmp/*

RUN printf "#!/bin/sh\n_ansible_playbook() { . /ansible-env/bin/activate && command ansible-playbook "'"$@"'" ; deactivate; }; _ansible_playbook "'"$@"'"" > /usr/bin/ansible-playbook && \
    chmod +x /usr/bin/ansible-playbook && \
    printf "#!/bin/sh\n_az() { . /azure-env/bin/activate && command az "'"$@"'" ; deactivate; }; _az "'"$@"'"" > /usr/bin/az && \
    chmod +x /usr/bin/az
