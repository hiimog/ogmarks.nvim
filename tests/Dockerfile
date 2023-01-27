FROM ubuntu:jammy

ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install sudo

# create user developer and remove password for sudo
RUN groupadd -g 999 developer \
    && useradd -u 999 -g developer -G sudo -m -s /bin/bash developer \
    && sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' \
    && sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' \
    && sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' \
    && echo "developer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo "Customized the sudoers file for passwordless access to the developer user!" \
    && echo "developer user:";  su - developer -c id

USER developer

RUN echo "developer:developer" | sudo chpasswd

ENV SHELL=/bin/bash
ENV PATH="/home/developer/.local/bin:${PATH}"

WORKDIR /home/developer

RUN sudo apt-get -qq update && sudo apt-get -qq install \
    build-essential     \
    git                 \
    libreadline-dev     \
    libsqlite3-dev      \
    lua5.1              \
    luarocks            \
    python3-pip         \
    python3.10          \
    sqlite3             \
    unzip               \
    wget                \
    && sudo ln -s /usr/bin/python3.10 /usr/bin/python

RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb \
    && sudo dpkg -i nvim-linux64.deb \
    && rm nvim-linux64.deb

RUN pip install neovim-remote

RUN sudo luarocks install lsqlite3 \
    && sudo luarocks install penlight

RUN git clone https://github.com/ii14/neorepl.nvim.git ~/.config/nvim/

COPY . /src/ogmarks.nvim

RUN sudo chown -R developer /src && sudo chgrp -R developer /src

WORKDIR /src/ogmarks.nvim/tests

#CMD ["nvim", "--headless", "-u", "spec.vim", "-c", "PlenaryBustedDirectory specs/ {minimal_init = 'spec.vim'}"]