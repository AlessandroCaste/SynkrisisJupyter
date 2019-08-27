FROM openjdk:11.0.3-jdk

RUN apt-get update \
&& apt-get install -y graphviz \
&& apt-get install -y python3-pip \
&& apt-get install -y autoconf \
&& apt-get install -y automake \
&& apt-get install -y m4 \
&& apt-get install -y perl \
&& apt-get install -y libtool \
&& apt-get install -y google-perftools \
&& apt-get install -y flex bison \
&& apt-get install -y libreadline-dev \
&& apt-get install -y texinfo \
&& apt-get install -y gcc \
&& apt-get install -y g++  \
&& apt-get install -y python3-pip 

# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir jupyter jupyterlab
RUN pip3 install jupyterthemes
USER root

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
ENV PATH /home/$NB_USER/lib/spot_installation/bin:$PATH
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
    && ./configure --prefix ~/spot_installation \ 
    && make \
    && make install \
    && cd
