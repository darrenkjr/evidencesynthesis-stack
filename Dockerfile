#setup python environment
FROM python:3.11-slim AS automated_citation_search_st_builder
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/darrenkjr/automated_citationsearch_st.git automated_citation_search_app
WORKDIR /automated_citation_search_app
RUN pip --no-cache-dir install -r requirements.txt
CMD ["streamlit", "run", "main.py", "--server.port", "${PORT}", "--server.address=0.0.0.0"]

#setup R shiny environment 
FROM rocker/shiny-verse:latest AS searchbuildR_builder
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && R -e "install.packages('remotes', repos = 'https://cran.rstudio.com')"

RUN R -e "remotes::install_github('darrenkjr/searchbuildR_docker')"
CMD ["R", "-e", "library(searchbuildR); searchbuildR::run_app(host='0.0.0.0', port= ${PORT})"]


#build the images
FROM automated_citation_search_st_builder AS automated_citation_search_st_image
FROM searchbuildR_builder AS searchbuildR_image
