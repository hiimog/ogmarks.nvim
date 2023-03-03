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
RUN sudo apt-get update -y
RUN sudo apt-get -y install curl
RUN sudo apt-get -y install unzip
RUN sudo apt-get -y install wget
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - && sudo apt-get install -y nodejs  
RUN sudo npm i -g yarn                                                                                   
RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb                      
RUN sudo dpkg -i nvim-linux64.deb
RUN rm nvim-linux64.deb
RUN sudo mkdir -p /src/ogmarks.nvim
RUN sudo chown -R developer /src && sudo chgrp -R developer /src
WORKDIR /src/ogmarks.nvim
RUN mkdir -p ~/.config/nvim/rplugin/node/ogmarks.nvim
RUN yarn global add neovim
COPY . /src/ogmarks.nvim
RUN yarn
RUN yarn test:build
CMD yarn test:run