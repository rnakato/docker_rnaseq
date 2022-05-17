### Docker image for RNA-seq analysis
# Installed tools:
# STAR v2.7.10a
# RSEM v1.3.3
# salmon v1.7.0
# edgeR 3.28.0
# hisat v2.2.1
# stringtie v2.2.1
# ballgown 2.18.0
# kallisto v0.46.1
# sleuth 0.30.0

FROM rnakato/r_python:20.04
MAINTAINER Ryuichiro Nakato <rnakato@iqb.u-tokyo.ac.jp>

WORKDIR /opt

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt update \
    && apt install -y --no-install-recommends \
    build-essential \
    libboost-all-dev \
    libbz2-dev \
    libcurl4-gnutls-dev \
    libgtkmm-3.0-dev \
    libgzstream0 \
    libgzstream-dev \
    liblzma-dev \
    libz-dev \
    cmake \
    curl \
    pigz \
    && apt clean \
    && rm -rf /var/lib/apt/list

# BWA 0.7.17
COPY bwa-0.7.17.tar.bz2 bwa-0.7.17.tar.bz2
RUN tar xvfj bwa-0.7.17.tar.bz2 \
    && cd bwa-0.7.17 \
    && make \
    && rm /opt/bwa-0.7.17.tar.bz2

# Bowtie1.3.1
COPY bowtie-1.3.1-linux-x86_64.zip bowtie-1.3.1-linux-x86_64.zip
RUN unzip bowtie-1.3.1-linux-x86_64.zip \
    && rm bowtie-1.3.1-linux-x86_64.zip

# Bowtie2.4.5
COPY bowtie2-2.4.5-linux-x86_64.zip bowtie2-2.4.5-linux-x86_64.zip
RUN unzip bowtie2-2.4.5-linux-x86_64.zip \
    && rm bowtie2-2.4.5-linux-x86_64.zip

# Samtools 1.15.1
COPY samtools-1.15.1.tar.bz2 samtools-1.15.1.tar.bz2
RUN tar xvfj samtools-1.15.1.tar.bz2 \
    && cd samtools-1.15.1 \
    && ./configure \
    && make && make install \
    && rm /opt/samtools-1.15.1.tar.bz2

RUN git clone --recursive https://github.com/rnakato/ChIPseqTools.git \
    && cd ChIPseqTools \
    && make

RUN wget https://github.com/alexdobin/STAR/archive/2.7.10a.tar.gz \
    && tar xzvf 2.7.10a.tar.gz \
    && cd STAR-2.7.10a/source \
    && make \
    && rm /opt/2.7.10a.tar.gz

RUN curl -s https://cloud.biohpc.swmed.edu/index.php/s/oTtGWbWjaxsQ2Ho/download > hisat2-2.2.1-Linux_x86_64.zip \
    && unzip hisat2-2.2.1-Linux_x86_64.zip \
    && rm hisat2-2.2.1-Linux_x86_64.zip

RUN wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz \
    && tar zxvf stringtie-2.2.1.Linux_x86_64.tar.gz \
    && rm /opt/stringtie-2.2.1.Linux_x86_64.tar.gz

RUN wget https://github.com/deweylab/RSEM/archive/refs/tags/v1.3.3.tar.gz \
    && tar zxvf v1.3.3.tar.gz \
    && cd RSEM-1.3.3/ \
    && make \
    && rm /opt/v1.3.3.tar.gz

RUN wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz \
    && tar zxvf kallisto_linux-v0.46.1.tar.gz \
    && R -e "devtools::install_github('pachterlab/sleuth')" \
    && rm kallisto_linux-v0.46.1.tar.gz

RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v1.8.0/salmon-1.8.0_linux_x86_64.tar.gz \
    && tar zxvf salmon-1.8.0_linux_x86_64.tar.gz \
    && rm salmon-1.8.0_linux_x86_64.tar.gz

RUN R -e "BiocManager::install(c('multtest', 'apeglm', 'limma', 'edgeR', 'DESeq2', 'Rtsne', 'tximport', 'tximportData', 'preprocessCore', 'rhdf5', 'ballgown', 'DEXSeq'))"
RUN R -e "install.packages(c('som','ggfortify','ggrepel','gplots'))"

COPY NCBI NCBI
#COPY Database Database
COPY script script

ENV PATH ${PATH}:/opt/RSEM-1.3.3:/opt/STAR-2.7.10a/bin/Linux_x86_64:/opt/kallisto:/opt/salmon-1.8.0_linux_x86_64/bin/:/opt/hisat2-2.2.1:/opt/stringtie-2.2.1.Linux_x86_64:/opt/script:/opt/ChIPseqTools/bin/:/opt:/opt/bwa-0.7.17:/opt/bowtie-1.3.1-linux-x86_64:/opt/bowtie2-2.4.5-linux-x86_64

WORKDIR /work
