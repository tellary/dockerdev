FROM debian:buster-20210511 AS haskell-stack

ARG username=ilya
ARG tz='US/Pacific'

RUN sed -i 's/main/main contrib/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git git-doc git-man
RUN apt-get install -y haskell-stack
RUN stack upgrade

# To make `cabal install` work.
# Also, zlib is required to build the `digest` Haskell package
RUN apt-get install -y pkg-config gcc libgmp-dev zlib1g-dev

# The main reason to have separate `haskell-builds` stage is to avoid
# interference between the "main" stage and `haskell-builds`:
# I don't want to rebuild anything under `haskell-builds` due to a change in the
# "main" stage, and vice versa.
FROM haskell-stack AS haskell-builds

RUN mkdir artifacts

RUN git clone https://github.com/tellary/tasktags.git && \
    cd tasktags && \
    git checkout 9fd14ed3bc5ed00371732fab1b517939653644c7 && \
    stack setup
RUN cd tasktags && stack build --flag tasktags:release
RUN cd tasktags && \
    cp $(stack path --local-install-root)/bin/keepToMd /artifacts && \
    cp $(stack path --local-install-root)/bin/togglCsv /artifacts && \
    cp $(stack path --local-install-root)/bin/togglSubmit /artifacts && \
    cd .. && rm -rf tasktags

RUN git clone https://github.com/tellary/anki-md.git && \
    cd anki-md && \
    stack setup
RUN cd anki-md && stack build
RUN cd anki-md && \
    cp $(stack path --local-install-root)/bin/ankiMd /artifacts && \
    cd .. && rm -rf anki-md

RUN git clone https://github.com/tellary/pandoc-plantuml-filter.git && \
    cd pandoc-plantuml-filter && \
    stack setup
RUN cd pandoc-plantuml-filter && stack build
RUN cd pandoc-plantuml-filter && \
    cp $(stack path --local-install-root)/bin/pandoc-plantuml-filter /artifacts && \
    cd .. && rm -rf pandoc-plantuml-filter

FROM haskell-stack

RUN apt-get install -y \
    python \
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
RUN apt-get install -y python3-matplotlib python3-numpy python3-tk \
                       python-mpltoolkits.basemap python3-scipy dvipng
RUN apt-get install -y sysstat
RUN apt-get install -y libbz2-dev
RUN apt-get install -y libzip-dev
RUN apt-get install -y libblas-dev liblapack-dev
RUN apt-get install -y libgsl-dev
RUN apt-get install -y apt-rdepends
RUN apt-get install -y rsync
RUN apt-get install -y locate

# pinentry-curses doesn't work in emacs
RUN apt-get remove -y pinentry-curses

RUN apt-get update && sudo apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        apt-key add - && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | \
        tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl=1.6.1-00 && \
    apt-mark hold kubectl

RUN apt-get install -y make
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install awscli==1.16.121 --root / --compile
RUN apt-file update

RUN echo 'en_US.UTF-8 UTF-8 ' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo 'export LANG=en_US.UTF-8 ' >> /etc/profile
RUN echo 'export LC_ALL=en_US.UTF-8 ' >> /etc/profile
RUN echo 'export LANGUAGE=en_US.UTF-8 ' >> /etc/profile

RUN apt-get install -y haskell-platform haskell-platform-prof haskell-stack
RUN apt-get install -y cpphs

RUN cabal update

RUN apt-get install -y pandoc libghc-pandoc-dev
RUN apt-get install -y libghc-haxml-dev libghc-http-dev libghc-wreq-dev \
    libghc-xml-conduit-dev libghc-resource-pool-dev

RUN apt-get install -y tigervnc-standalone-server chromium
RUN apt-get install -y openbox

RUN apt-get install -y libghc-regex-pcre-dev libghc-regex-posix-dev
RUN apt-get install -y libghc-old-time-dev
RUN apt-get install -y libghc-quickcheck2-dev

RUN apt-get install -y netpbm

RUN apt-get install -y libghc-split-dev libghc-pretty-simple-dev libghc-ini-dev
RUN apt-get install -y libghc-email-validate-dev
RUN apt-get install -y stylish-haskell
RUN apt-get install -y libghc-reflection-dev

RUN apt-get install -y sqlite3 libsqlite3-dev
RUN apt-get install -y libghc-hdbc-dev libghc-hdbc-sqlite3-dev

RUN apt-get install -y lsof

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

ADD html /usr/local/bin
RUN chmod 755 /usr/local/bin/html
ADD pdf /usr/local/bin
RUN chmod 755 /usr/local/bin/pdf

RUN echo export TERM=xterm-256color >> /home/${username}/.profile

RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${tz} /etc/localtime

# It didn't pass the hash-sum check last time
# RUN curl -L -o spark.tgz https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz
# COPY spark.sha512 .
# RUN EXPECTED_HASH=$( cat spark.sha512 ) && \
#     ACTUAL_HASH=$(sha512sum spark.tgz | cut -f 1 -d ' ') && \
#     [ $EXPECTED_HASH = $ACTUAL_HASH ] && \
#     mkdir spark && \
#     tar xf spark.tgz -C spark && \
#     mv spark/* /opt/spark && \
#     echo 'export PATH=$PATH:/opt/spark/bin' >> /etc/profile
# RUN rm -rf spark spark.tgz spark.sha512

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
RUN chmod 755 /usr/local/bin/plantuml
ADD plantuml.1.2019.11.jar /usr/local/bin/plantuml.jar

COPY ssh-agent.sh /etc/profile.d/

ADD findtags /usr/local/bin
RUN chmod 755 /usr/local/bin/findtags

ADD mdunwrap /usr/local/bin
RUN chmod 755 /usr/local/bin/mdunwrap

ADD get-maven-source.pl /usr/local/bin/get-maven-source
RUN chmod 755 /usr/local/bin/get-maven-source

RUN wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.16.0/pmd-bin-6.16.0.zip && \
    unzip pmd-bin-6.16.0.zip && \
    mv pmd-bin-6.16.0 /opt && \
    rm pmd-bin-6.16.0.zip
ADD pmd.sh /usr/local/bin/pmd
RUN chmod 755 /usr/local/bin/pmd

RUN mkdir -p /home/${username}/.config/nix && \
    echo "sandbox = false" > /home/${username}/.config/nix/nix.conf && \
    chown -R ${username}.${username} /home/${username}/.config/nix && \
    mkdir -m 0755 /nix && chown ${username}.${username} /nix && \
    export NIX_RELEASE=2.3.4 && \
    wget -O- "https://nixos.org/releases/nix/nix-$NIX_RELEASE/nix-$NIX_RELEASE-x86_64-linux.tar.xz" > nix.tar.xz && \
    tar -xJvf nix.tar.xz && \
    su ${username} -c nix-*-x86_64-linux/install && \
    rm nix.tar.xz && rm -r nix-*-x86_64-linux

VOLUME /nix

ADD .emacs .
RUN chown ${username}.${username} .emacs

RUN mkdir .emacs.d && chown ${username}.${username} .emacs.d

RUN mkdir -p ${projects_dir}myemacs && \
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
          ${user_dir}.ctags && \
    ln -s ${config_dir}.tasktags \
          ${user_dir}.tasktags
ADD install-packages.el .
RUN chmod 755 install-packages.el
RUN su ${username} -c "emacs --script /home/${username}/install-packages.el"
RUN rm install-packages.el

# ADD jdk8.tar.gz .
# RUN mv jdk1.8.* /opt/ && \
#     ln -s /opt/jdk1.8.* /opt/jdk1.8
ADD jdk11.tar.gz .
RUN mv jdk-11* /opt/ && \
    ln -s /opt/jdk-11* /opt/jdk11 && \
    ls /opt/jdk11/bin | \
        while read file; \
        do \
            ln -s /opt/jdk11/bin/$file /usr/local/bin/$file; \
        done;
# TODO add hash sum verification
RUN curl -L -o gradle7.zip https://services.gradle.org/distributions/gradle-7.1-bin.zip
RUN unzip gradle7.zip && rm -f gradle7.zip && \
    mv gradle-7.* /opt/ && \
    ln -s /opt/gradle-7.* /opt/gradle-7 && \
    ln -s /opt/gradle-7/bin/gradle /usr/local/bin/gradle;

COPY --from=haskell-builds /artifacts/* /usr/local/bin

ENV USER ${username}

# Use `cabal install` to maintain user Haskell package database
# across containers like Gradle.
# The volumes are still to be mounted when starting a container.
RUN mkdir -p ${user_dir}.cabal
RUN mkdir -p ${user_dir}.cabal/bin
RUN mkdir -p ${user_dir}.ghc
RUN mkdir -p ${user_dir}.gradle
RUN chown -R ${username}.${username} ${user_dir}.cabal
RUN chown -R ${username}.${username} ${user_dir}.ghc
RUN chown -R ${username}.${username} ${user_dir}.gradle
VOLUME ${user_dir}.cabal
VOLUME ${user_dir}.ghc
VOLUME ${user_dir}.gradle
VOLUME ${user_dir}.stack

ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
