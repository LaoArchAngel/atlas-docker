FROM ubuntu:18.04

## Install dependencies
##RUN yum -y install glibc.i686 libstdc++.i686 git lsof bzip2 cronie perl-Compress-Zlib \
## && yum clean all \
## && adduser -u $ARK_UID -s /bin/bash -U steam

# Install multiverse
RUN apt-get update && \
  apt-get install -y software-properties-common debconf-utils apt-utils debconf-i18n sudo && \
  apt-get update && \
  add-apt-repository multiverse && \
  dpkg --add-architecture i386

# Seed steam auto-accept
RUN echo 'steamcmd steam/question select I AGREE' | debconf-set-selections
RUN echo 'steamcmd steam/license note ""' | debconf-set-selections
 
# Install dependencies 
RUN apt-get update &&\ 
    apt-get install -y curl lib32gcc1 lsof git cron libidn11 steamcmd redis-server jq
    
RUN adduser \ 
	--disabled-login \ 
	--shell /bin/bash \ 
	--gecos "" \ 
	steam

# Add to sudo group
RUN usermod -a -G sudo steam

# Install atlas-server-tools
RUN curl -sL http://git.io/fh4HA | sudo bash -s steam

# Copy & rights to folders
RUN  mkdir /atlas \
  && mkdir /atlas/logs \
  && chown steam /atlas \
  && chmod -R 755 /atlas

# RCon ports
EXPOSE 32350-32375

# Game Ports
EXPOSE 57525-57575 57525-57575/udp

# Query Ports
EXPOSE 5750-5775 5750-5775/udp

# Seamless Ports
EXPOSE 27000-27025 27000-27025/udp

VOLUME /atlas/server/ShooterGame/Saved

# Change the working directory to /ark
WORKDIR /atlas

# Update game launch the game.
ENTRYPOINT ["/bin/bash"]
