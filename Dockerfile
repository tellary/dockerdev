FROM debian

ARG username=ilya
ARG tz='US/Pacific'

RUN sed -i 's/main/main contrib/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y \
    python git git-doc git-man \
    haskell-platform gnupg2 \
    emacs-nox less vim \
    curl wget ssh \
    typespeed \
    hunspell hunspell-ru hunspell-en-us \
    apg \
    locales \
    sudo \
    man netcat \
    apt-file
RUN apt-file update

RUN echo 'en_US.UTF-8 UTF-8 ' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo 'export LANG=en_US.UTF-8 ' >> /etc/profile
RUN echo 'export LC_ALL=en_US.UTF-8 ' >> /etc/profile
RUN echo 'export LANGUAGE=en_US.UTF-8 ' >> /etc/profile

RUN cabal update
RUN cabal install Cabal
RUN cabal install --global pandoc

RUN useradd -m -s /bin/bash ${username}
ADD chpasswd.use chpasswd
RUN sed -i 's/@username/'${username}'/' chpasswd
RUN cat chpasswd | chpasswd
RUN rm chpasswd

ENV user_dir /home/${username}/
ENV safeplace_dir ${user_dir}safeplace/
ENV projects_dir ${safeplace_dir}projects/
ENV config_dir ${safeplace_dir}config/

VOLUME ${safeplace_dir}

WORKDIR ${user_dir}

ADD .emacs .
RUN chown ${username}.${username} .emacs

RUN mkdir .emacs.d && chown ${username}.${username} .emacs.d
ADD zenburn-theme.el .emacs.d/
ADD cyrillic-dvorak.el .emacs.d/
RUN chown ${username}.${username} .emacs.d/cyrillic-dvorak.el
ADD drools-mode.el .emacs.d/
RUN chown ${username}.${username} .emacs.d/drools-mode.el

RUN mkdir -p ${projects_dir}meta-bindings && \
    touch ${projects_dir}meta-bindings/meta-bindings.el && \
    ln -s ${projects_dir}meta-bindings/meta-bindings.el \
          .emacs.d/meta-bindings.el && \
    mkdir -p ${projects_dir}myemacs && \
    ln -s ${projects_dir}myemacs \
          .emacs.d/myemacs

ADD install-packages.el .
RUN chmod 755 install-packages.el
RUN su ${username} -c "emacs --script /home/${username}/install-packages.el"
RUN rm install-packages.el

RUN ln -s ${config_dir}.hunspell_en_US \
          ${user_dir}.hunspell_en_US && \
    ln -s ${config_dir}.hunspell_ru_RU \
          ${user_dir}.hunspell_ru_RU && \
    mkdir -p ${projects_dir}/myconfig && \
    ln -s ${projects_dir}/myconfig/.gitignore \
          ${user_dir}.gitignore && \
    ln -s ${config_dir}.gitconfig \
          ${user_dir}.gitconfig && \          
    ln -s ${projects_dir}/myconfig/.ctags \
          ${user_dir}.ctags

ADD html /usr/local/bin
RUN chmod 755 /usr/local/bin/html

RUN echo export TERM=xterm-256color >> /home/${username}/.profile

ADD jdk8.tar.gz .
RUN mv jdk1.8.* /opt/ && \
    ln -s /opt/jdk1.8.* /opt/jdk1.8.0 && \
    ls /opt/jdk1.8.0/bin | \
        while read file; \
        do \
            ln -s /opt/jdk1.8.0/bin/$file /usr/local/bin/$file; \
        done;

RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${tz} /etc/localtime

# TODO move to the above
RUN apt-get install -y \
    emacs-goodies-el \
    strace \
    pinentry-tty
# pinentry-curses doesn't work in emacs
RUN apt-get remove -y pinentry-curses

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# RUN curl https://nodejs.org/dist/v7.3.0/node-v7.3.0.pkg

# TODO: Install latest node.js
# TODO: Install Oracle JDK 8 https://wiki.debian.org/Java/Sun

