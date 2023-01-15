FROM python:3.8-slim-buster

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV POETRY_VERSION=1.3.2
ARG ENV

ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

RUN mkdir -p /src/

RUN apt-get update && apt-get install -y --no-install-recommends libgdal-dev \
    && apt-get autoclean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  \
    && pip install "poetry==$POETRY_VERSION" \
    && poetry config virtualenvs.create false

COPY poetry.lock /src/poetry.lock
COPY pyproject.toml /src/pyproject.toml
COPY setup.cfg /src/setup.cfg

RUN cd /src && poetry install

COPY src/ /src/
WORKDIR /src/

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

