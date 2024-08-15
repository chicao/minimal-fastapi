
## TO DOs

Set up docker

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

```bash
$ docker network inspect bridge -f '{{json .Containers}}'
```