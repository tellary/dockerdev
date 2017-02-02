FROM debian

ARG username=ilya

RUN sed -i 's/main/main contrib/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y \
    python git git-doc git-man \
    haskell-platform gnupg2 \
    emacs-nox less vim \
    curl wget ssh \
    java-package

RUN useradd -m -s /bin/bash ${username}
ADD chpasswd .
RUN sed -i 's/@username/'${username}'/' chpasswd
RUN cat chpasswd | chpasswd
RUN rm chpasswd

RUN apt-get install -y typespeed hunspell
RUN apt-get install -y pandoc

ENV user_dir /home/${username}/
ENV safeplace_dir ${user_dir}safeplace/
ENV projects_dir ${safeplace_dir}projects/
ENV config_dir ${safeplace_dir}config/

VOLUME ${safeplace_dir}

WORKDIR ${user_dir}

ADD .emacs .

RUN mkdir .emacs.d && \
    mkdir -p ${projects_dir}meta-bindings && \
    touch ${projects_dir}meta-bindings/meta-bindings.el && \
    ln -s ${projects_dir}meta-bindings/meta-bindings.el \
          .emacs.d/meta-bindings.el && \
    mkdir -p ${projects_dir}myemacs && \
    ln -s ${projects_dir}myemacs \
          .emacs.d/myemacs && \
    ln -s ${config_dir}.hunspell_en_US \
          ${user_dir}.hunspell_en_US && \
    ln -s ${config_dir}.hunspell_ru_RU \
          ${user_dir}.hunspell_ru_RU

ADD html /usr/local/bin
RUN chmod 755 /usr/local/bin/html

# RUN curl https://nodejs.org/dist/v7.3.0/node-v7.3.0.pkg

# TODO: Install latest node.js
# TODO: Install Oracle JDK 8 https://wiki.debian.org/Java/Sun

