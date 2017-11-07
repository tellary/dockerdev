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
    apt-file \
    emacs-goodies-el \
    strace \
    pinentry-tty \
    jq \
    xterm xsel xclip \
    net-tools \
    zip unzip
# pinentry-curses doesn't work in emacs
RUN apt-get remove -y pinentry-curses
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
    ln -s /opt/jdk1.8.* /opt/jdk1.8 && \
    ls /opt/jdk1.8/bin | \
        while read file; \
        do \
            ln -s /opt/jdk1.8/bin/$file /usr/local/bin/$file; \
        done;

RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${tz} /etc/localtime

# TODO add hash sum verification
RUN curl -L -o gradle4.zip https://services.gradle.org/distributions/gradle-4.2.1-bin.zip
RUN unzip gradle4.zip && rm -f gradle4.zip && \
    mv gradle-4.* /opt/ && \
    ln -s /opt/gradle-4.* /opt/gradle-4 && \
    ln -s /opt/gradle-4/bin/gradle /usr/local/bin/gradle;

ARG nodejs_version=8.7.0
ENV nodejs_dir=node-v${nodejs_version}-linux-x64
ENV nodejs_file=${nodejs_dir}.tar.xz

RUN curl -L -o $nodejs_file http://nodejs.org/dist/v8.7.0/$nodejs_file
COPY nodejs_shasums256.txt.asc .
RUN EXPECTED_HASH=$( \
        grep ${nodejs_file} nodejs_shasums256.txt.asc | \
            cut -f 1 -d ' ') && \
    ACTUAL_HASH=$(sha256sum $nodejs_file | cut -f 1 -d ' ') && \
    [ $EXPECTED_HASH = $ACTUAL_HASH ] && \
    tar xf $nodejs_file && \
    mv $nodejs_dir /opt && \
    ls /opt/$nodejs_dir/bin | \
        while read file; \
        do \
            ln -s /opt/$nodejs_dir/bin/$file /usr/local/bin/$file; \
        done;

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]

