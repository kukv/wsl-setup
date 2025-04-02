FROM ubuntu:24.10

ARG USER=tech

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        ansible \
        systemd \
        init \
        git \
        sudo \
        gnupg2 \
        systemd-resolved \
        systemd-timesyncd \
        && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m $USER -s /bin/bash && \
    echo "$USER:$USER" | chpasswd && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    mkdir -p /home/$USER \

WORKDIR /home/$USER

CMD [ "/sbin/init" ]
