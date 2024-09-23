#
#   Multistage dockerfile to deal with different execution scenarios
#   ref.: https://docs.docker.com/develop/develop-images/multistage-build/
#

# Ref.: https://docs.python.org/3/using/cmdline.html
FROM python:3.12-slim-bullseye AS python-base
ENV PYTHONUNBUFFERED=1 \                                
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# builder-base is used to build dependencies
FROM python-base AS builder-base
RUN buildDeps="build-essential" \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        vim \
        netcat \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
ENV POETRY_VERSION=1.8.3
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 - --version ${POETRY_VERSION} && \
    chmod a+x /opt/poetry/bin/poetry

# # We copy our Python requirements here to cache them
# # and install only runtime deps using poetry
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry install --only main

# # 'development' stage installs all dev deps and can be used to develop code.
# # For example using docker-compose to mount local volume under /app
FROM python-base AS development
ENV FASTAPI_ENV=development

# # Copying poetry and venv into image
COPY --from=builder-base $POETRY_HOME $POETRY_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

# # Copying in our entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# # venv already has runtime deps installed we get a quicker install
WORKDIR $PYSETUP_PATH
RUN poetry install

WORKDIR /app
COPY . .

EXPOSE 8000
ENTRYPOINT /docker-entrypoint.sh $0 $@
CMD ["uvicorn", "--reload", "--host=0.0.0.0", "--port=8000", "minimal_fastapi.main:app"]

# # 'lint' stage runs black and isort
# # running in check mode means build will fail if any linting errors occur
FROM development AS lint
RUN black --config ./pyproject.toml --check minimal_fastapi tests
RUN isort --settings-path ./pyproject.toml --recursive --check-only
CMD ["tail", "-f", "/dev/null"]


################################################################################
####    PRODUCTION CONF                                                     ####
####    ref.: https://www.uvicorn.org/#running-with-gunicorn                ####
####    From uvicorn docs :                                                 ####
####    "For production deployments we recommend using gunicorn             ####
####    with the uvicorn worker class". Gunicorn's fully-featured process   ####
####    management. It allows to increase or decrease the number of worker  ####
####    processes on the fly, restart worker processes gracefully, or       ####
####    perform server upgrades without downtime.                           ####
####                                                                        ####
################################################################################


# # 'production' stage uses the clean 'python-base' stage and copyies
# # in only our runtime deps that were installed in the 'builder-base'
FROM python-base AS production
ENV FASTAPI_ENV=production

COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY gunicorn_conf.py /gunicorn_conf.py

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# # Create user with the name poetry
RUN groupadd -g 1500 poetry && \
    useradd -m -u 1500 -g poetry poetry

COPY --chown=poetry:poetry ./minimal_fastapi /app
USER poetry
WORKDIR /app

ENTRYPOINT /docker-entrypoint.sh $0 $@
CMD [ "gunicorn", "--worker-class uvicorn.workers.UvicornWorker", "--config /gunicorn_conf.py", "main:app"]