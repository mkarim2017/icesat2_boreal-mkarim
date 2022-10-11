FROM continuumio/miniconda3:4.10.3p1

# To prevent cached builds from fudging the resulting image, may or may not be necessary.
ARG CACHEBUST=1

RUN mkdir /projects
WORKDIR /projects
RUN sed -i -e 's/\/root/\/projects/g' /etc/passwd

RUN conda install gdal
RUN conda install -c conda-forge Cython
RUN conda install -c conda-forge h5py
RUN conda install -c conda-forge numba
RUN conda install -c conda-forge pygeos
#RUN conda install -c conda-forge/label/cf202003 pyproj
#RUN conda update -c conda-forge pyproj
RUN conda install -c conda-forge pyproj
RUN conda install -c conda-forge rasterio
RUN conda install -c conda-forge scipy
# Install matplotlib since it required to install maap-py dep mapboxgl
RUN conda install -c conda-forge matplotlib

##################################
# Break the cache after this point
ARG CACHEBUST=1
##################################

# install maap-py library
ENV MAAP_CONF='/projects/maap-py/'
RUN git clone --single-branch --branch master https://github.com/MAAP-Project/maap-py.git \
    && cd maap-py \
    && python setup.py install


# Remove the DST Root CA X3 certificate and update certs. 
# We should consider removing these two commands after upgrading from miniconda3:4.7.12
# For more info, see: https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/
RUN sed -i 's/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf
RUN update-ca-certificates


ARG version
ENV DOCKERIMAGE_PATH='mas.maap-project.org:5000/root/ade-base-images/vanilla:latest'


# Boilerplate required due to using a manual Dockerfile
RUN python3 -m pip install papermill
COPY . /home/jovyan
RUN /bin/bash /home/jovyan/icesat2_boreal/dps/build_command_main.sh
