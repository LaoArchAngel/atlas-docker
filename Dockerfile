FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

# Install apt-utils first
RUN apt-get update && apt-get install -y apt-utils

# Install multiverse
RUN apt-get upgrade -y && \
  apt-get install -y software-properties-common debconf-utils debconf-i18n sudo && \
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

COPY --chown=steam:steam entrypoint.sh /home/steam/entrypoint.sh

RUN chmod +x /home/steam/entrypoint.sh

# RCon ports
EXPOSE 32350-32375

# Game Ports
EXPOSE 57525-57575 57525-57575/udp

# Query Ports
EXPOSE 5750-5775 5750-5775/udp

# Seamless Ports
EXPOSE 27050-27075 27050-27075/udp

VOLUME [ "/atlas/server/ShooterGame/Saved", "/atlas/config", "/etc/atlasmanager/instances" ]

# Change the working directory to /atlas
WORKDIR /atlas

# Create a steam-owned atlasmanager config
RUN mkdir /atlas/staging \
 && mkdir /atlas/config/instances \
 && cp /etc/atlasmanager/atlasmanager.cfg /atlas/staging \
 && echo "" >> /etc/atlasmanager/atlasmanager.cfg \
 && echo "source /atlas/config/atlasmanager.cfg" >> /etc/atlasmanager/atlasmanager.cfg

# Point settings to atlas folder
RUN sed -i 's/atlasserverroot=.*/atlasserverroot="\/atlas\/server"/' /atlas/staging/atlasmanager.cfg \
  && sed -i 's/atlasbackupdir=.*/atlasbackupdir="\/atlas\/backup"/' /atlas/staging/atlasmanager.cfg \
  && sed -i 's/^#\?atlasStagingDir=.*/atlasStagingDir="\/atlas\/staging"/' /atlas/staging/atlasmanager.cfg

# Move instance configs to atlas folder
RUN cp -Ra /etc/atlasmanager/instances /atlas/staging

RUN chown -R steam:steam /atlas \
  && chown -R root:steam /etc/atlasmanager \
  && chmod 774 -R /etc/atlasmanager

USER steam:steam

# Update game launch the game.
ENTRYPOINT ["/home/steam/entrypoint.sh"]
