FROM ubuntu:noble-20241011

# Add user
RUN set -ex ;\
    useradd ansible -ms /bin/bash

WORKDIR /home/ansible

RUN set -ex ;\
    apt-get update ;\
    apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common ;\
    apt-get install -y --no-install-recommends \ 
    ansible \
    curl \
    git \
    python3 \
    python3-pip \
    vim \
    tmux ;\
    rm -rf /var/lib/apt/lists/*

USER ansible
RUN set -ex ;\
    mkdir config ;\
    mkdir data ;\
    mkdir dsu ;\
    mkdir playbooks ;\
    mkdir .ssh ;\
    chmod 700 data ;\
    chmod 700 .ssh ;\
    chown ansible:ansible data ;\
    chown ansible:ansible .ssh

COPY --chown=ansible:ansible config/ ./config

SHELL ["/bin/bash", "-c"]

RUN set -ex ;\
    pip install --break-system-packages --no-cache-dir \
    -r config/requirements.txt ;\
    ansible-galaxy collection install \
    -r config/requirements.yml

COPY --chown=ansible:ansible .ansible.cfg .
COPY --chown=ansible:ansible fw-setup.sh .
COPY --chown=ansible:ansible .ansible.cfg .
COPY --chown=ansible:ansible playbooks/ ./playbooks/
COPY --chown=ansible:ansible dsu/ ./dsu/

RUN set -ex ;\
    ls -ls ;\
    ansible-galaxy collection build dsu/ccdc/ ;\
    ansible-galaxy collection install --offline dsu-ccdc-1.0.0.tar.gz ;\
    rm -rf dsu-ccdc-1.0.0.tar.gz ;\
    echo "force_color_prompt=yes" >> /home/ansible/.bashrc

ENTRYPOINT ["top", "-b"]