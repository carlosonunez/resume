FROM ubuntu

# prepare a user which runs everything locally! - required in child images!
RUN useradd --user-group --create-home --shell /bin/false app

ENV HOME=/home/app
WORKDIR $HOME

RUN apt-get update && \
    apt-get install -y build-essential \
      wget \
      context \
      git \
      python3-dev \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      python3-cffi \
      libcairo2 \
      libpango-1.0-0 \
      libpangocairo-1.0-0 \
      libgdk-pixbuf2.0-0 \
      libffi-dev \
      shared-mime-info
RUN wget https://github.com/jgm/pandoc/releases/download/2.2.1/pandoc-2.2.1-1-amd64.deb
RUN dpkg -i pandoc-2.2.1-1-amd64.deb  && rm pandoc-*.deb

# Add weasyprint
RUN pip3 install weasyprint

# Add emojis
RUN apt-get -y install fonts-noto-color-emoji

#Cleanup to reduce container size
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get remove -y wget && \ 
    apt-get autoclean && \
    apt-get clean

# Add additional fonts
RUN mkdir ~/.fonts
COPY .docker/fonts/ /home/app/.fonts
RUN fc-cache -f -v

ENV APP_NAME=resume

# Clean
USER app
WORKDIR $HOME/$APP_NAME
