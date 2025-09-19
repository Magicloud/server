FROM python:3-slim

ADD deep-searcher/ /deepsearcher/
WORKDIR /deepsearcher/

RUN pip3 install ollama && \
    pip3 install -e .

ADD config.yaml /deepsearcher/config.yaml

VOLUME [ "/root/.ollama" ]