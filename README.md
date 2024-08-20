
## TO DOs

1. Add `test`stage into `Dockerfile`

## SetUp project

```bash
$ cd minimal-fastapi
$ poetry install
```

## Development

### Linting....
```bash
poetry run black minimal_fastapi/
```

### Testing....

```bash
$ poetry run pytest tests
```

## Running...

```bash
$ poetry run uvicorn minimal_fastapi.main:app --reload --host localhost --port 8000
```

## Appendix

### `pyenv`

```bash
$ pyenv install 3.12.4
$ pyenv local 3.12.4
$ pyenv virtualenv minimal-fastapi
$ pyenv activate minimal-fastapi
```

[PyEnv docs](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation)
[PyEnv VirtualEnv docs](https://github.com/pyenv/pyenv-virtualenv)

### `poetry`
```bash
$ poetry config --list
cache-dir = "$HOME/.cache/pypoetry"
experimental.system-git-client = false
installer.max-workers = null
installer.modern-installation = true
installer.no-binary = null
installer.parallel = true
keyring.enabled = true
solver.lazy-wheel = true
virtualenvs.create = true
virtualenvs.in-project = null  # We want this to TRUE so VSCODE loads python version locally
virtualenvs.options.always-copy = false
virtualenvs.options.no-pip = false
virtualenvs.options.no-setuptools = false
virtualenvs.options.system-site-packages = false
virtualenvs.path = "{cache-dir}/virtualenvs"  # $HOME.cache/pypoetry/virtualenvs
virtualenvs.prefer-active-python = false
virtualenvs.prompt = "{project_name}-py{python_version}"
warnings.export = true
$ poetry config virtualenvs.in-project true
```

### Docker

Check containers IPs:
```shell
$ docker network inspect bridge -f '{{json .Containers}}'
```

Build images with:

```shell
docker build -t minimal-fastapi .
```

The Dockerfile uses multi-stage builds to run lint and test stages before building the production stage.
If linting or testing fails the build will fail.

You can stop the build at specific stages with the `--target` option:

```shell
# STAGE options are: development, production
docker build -t minimal-fastapi --target $STAGE .
```

We could then get a shell inside the container with:

```shell
docker run -it minimal-fastapi:dev bash
```

If you do not specify a target the resulting image will be the last image defined which in our case is the 'production' image.

Run the 'production' image:

```shell
docker run -it -p 8000:8000 minimal-fastapi:dev
```

Open your browser and go to [http://localhost:8000/redoc](http://localhost:8000/redoc) to see the API spec in ReDoc.

### Docker Compose

You can build and run the container with Docker Compose

```shell
docker compose up
```

Or, run in *detached* mode if you prefer.

> **NOTE** - If you use an older version of Docker Compose,
> you may need to uncomment the version in the docker-compose,yml file!