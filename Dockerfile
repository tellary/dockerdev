FROM debian:9.4

ARG username=ilya
ARG tz='US/Pacific'

RUN sed -i 's/main/main contrib/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
    python git git-doc git-man \
    gnupg2 \
    emacs-nox emacs-goodies-el \
    less vim \
    curl wget ssh \
    typespeed \
    hunspell hunspell-ru hunspell-en-us \
    libdatetime-perl libdatetime-format-strptime-perl
RUN apt-get install -y \    
    apg \
    locales \
    sudo \
    man netcat \
    apt-file \
    strace \
    pinentry-tty \
    jq \
    xterm xsel xclip \
    net-tools \
    zip unzip \
    time exuberant-ctags \
    graphviz
RUN apt-get install -y \
    texlive-latex-base \
    texlive-fonts-recommended
RUN apt-get install -y \
    texlive-latex-recommended
RUN apt-get install -y python-pandas ipython    
# To make `cabal install` work.
RUN apt-get install -y pkg-config gcc libgmp-dev zlib1g-dev
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

RUN mkdir haskell-platform && curl -L -o haskell-platform/haskell-platform.tar.gz \
    https://haskell.org/platform/download/8.2.2/haskell-platform-8.2.2-unknown-posix--core-x86_64.tar.gz
RUN EXPECTED_HASH=bd01bf2b34ea3d91b1c82059197bb2e307e925e0cb308cb771df45c798632b58 \
    ACTUAL_HASH=$(sha256sum haskell-platform/haskell-platform.tar.gz | cut -f 1 -d ' ') && \
    [ $EXPECTED_HASH = $ACTUAL_HASH ] && \
    cd haskell-platform && \
    tar xf haskell-platform.tar.gz && \
    ./install-haskell-platform.sh && \
    cd .. && rm -rf haskell-platform
RUN sed -i \
    's/"C compiler supports -no-pie","NO"/"C compiler supports -no-pie","YES"/g' \
    /usr/local/haskell/ghc-8.2.2-x86_64/lib/ghc-8.2.2/settings

RUN cabal update
RUN cabal install --prefix /usr/local pandoc-2.1.3

RUN useradd -m -s /bin/bash ${username}
RUN usermod -aG sudo ${username}
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
ADD pdf /usr/local/bin
RUN chmod 755 /usr/local/bin/pdf

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
    (ls /opt/$nodejs_dir/bin | \
        while read file; \
        do \
            ln -s /opt/$nodejs_dir/bin/$file /usr/local/bin/$file; \
        done;) && \
    rm $nodejs_file && \
    rm nodejs_shasums256.txt.asc

ADD plantuml /usr/local/bin/plantuml
ADD plantuml.1.2017.19.jar /usr/local/bin/plantuml.jar
RUN chmod 755 /usr/local/bin/plantuml && \
    git clone https://github.com/jodonoghue/pandoc-plantuml-filter.git && \
    cd pandoc-plantuml-filter && \
    git checkout 7a7ddd614747e77f226be168cb3974c57ab6ec5d && \
    sed -i 's/4.10/4.11/g' \
        pandoc-plantuml-filter.cabal && \
    cabal install --prefix /usr/local  && \
    cd .. && rm -rf pandoc-plantuml-filter

RUN curl -L -o linux64.tar.gz https://github.com/purescript/purescript/releases/download/v0.11.7/linux64.tar.gz && \
    tar xf linux64.tar.gz && \
    mv purescript/purs /usr/local/bin && \
    npm install -g --prefix /usr/local pulp bower && \
    rm -rf purescript && rm linux64.tar.gz

COPY ssh-agent.sh /etc/profile.d/

ADD findtags /usr/local/bin
RUN chmod 755 /usr/local/bin/findtags

RUN sudo npm install -global markdown2confluence
ADD conf /usr/local/bin
RUN chmod 755 /usr/local/bin/conf

ADD mdunwrap /usr/local/bin
RUN chmod 755 /usr/local/bin/mdunwrap

ADD get-maven-source.pl /usr/local/bin/get-maven-source
RUN chmod 755 /usr/local/bin/get-maven-source

RUN  apt-get update && sudo apt-get install -y apt-transport-https && \
     curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
         apt-key add - && \
     echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
         tee -a /etc/apt/sources.list.d/kubernetes.list && \
     apt-get update && apt-get install -y kubectl=1.6.1-00 && \
     apt-mark hold kubectl
# TODO move to apt-get
RUN apt-get install -y make
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install awscli==1.16.121 --root / --compile

ADD install-packages.el .
RUN chmod 755 install-packages.el
RUN su ${username} -c "emacs --script /home/${username}/install-packages.el"
RUN rm install-packages.el

RUN wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.16.0/pmd-bin-6.16.0.zip && \
    unzip pmd-bin-6.16.0.zip && \
    mv pmd-bin-6.16.0 /opt && \
    rm pmd-bin-6.16.0.zip
ADD pmd.sh /usr/local/bin/pmd
RUN chmod 755 /usr/local/bin/pmd

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]

