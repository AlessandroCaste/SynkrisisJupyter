FROM openjdk:11.0.3-jdk

RUN apt-get update
RUN apt-get install -y graphviz
RUN apt-get install -y python3-pip
RUN apt-get install -y autoconf
RUN apt-get install -y automake
RUN apt-get install -y m4
RUN apt-get install -y perl
RUN apt-get install -y libtool
RUN apt-get install -y google-perftools
RUN apt-get install -y flex bison
RUN apt-get install -y libreadline-dev
RUN apt-get install -y texinfo
RUN apt-get install -y gcc
RUN apt-get install -y g++ 
RUN apt-get install -y python3-pip

# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir -r requirements.txt) \
        || pip3 install --no-cache-dir jupyter jupyterlab
RUN pip3 install jupyterthemes
USER root

# Download the kernel release
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

# Unpack and install the kernel
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Install bigmc
RUN git clone https://github.com/AlessandroCaste/bigmc.git
RUN cd bigmc \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# Set up the user environment

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV PATH /usr/local/bigmc/bin:$PATH
ENV PATH /home/$NB_USER/lib/prism-4.5-linux64/bin:$PATH
ENV PATH /home/$NB_USER/spot/bin:$PATH
ENV BIGMC_HOME /usr/local/bigmc

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER
    
COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER 



# Launch the notebook server
WORKDIR $HOME
# Add bigmc to path
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

# PRISM installation
RUN cd lib/prism-4.5-linux64 \ 
   && ./install.sh

RUN cd lib/spot-2.8.1 \ 
    && ./configure --prefix ~/spot \ 
    && make \
    && make install \
    && cd
