# pixi-env

`pixi-env` adds global conda-style environments to `pixi` via a `pixi env ...` shell wrapper.

All environments are stored under one directory:

- default: `~/.pixi-envs`
- override: set `PIXI_ENV_HOME=/some/directory`

## Install

Install with:

```sh
curl -LsSf https://raw.githubusercontent.com/kszenes/pixi-env/refs/heads/master/install.sh | sh
```

Then enable activation/deactivation and the `pixi env ...` wrapper in your shell (`bash` or `zsh`):

```sh
eval "$(pixi-env shell-init)"
```

Add that line to `~/.bashrc` or `~/.zshrc` to make it permanent.

## Usage

```sh
pixi env create -n py311 python=3.11 numpy
pixi env list
pixi env activate py311
python --version
pixi env deactivate
```

More commands:

```sh
pixi add pandas matplotlib              # adds to active pixi-env env
pixi env add pandas matplotlib          # same as above
pixi env add -n py311 pandas matplotlib # explicit env
pixi env run -n py311 -- python -c 'import numpy; print(numpy.__version__)'
pixi env path                           # prints the env root directory
pixi env path -n py311                  # prints one env directory
pixi env remove -n py311
```

`pixi-env` remains available as the backend command if you prefer it:

```sh
pixi-env create -n py311 python=3.11
pixi-env activate py311
```

## Notes

Each global environment is a normal pixi project stored at `$PIXI_ENV_HOME/<name>`. Its default environment prefix is `$PIXI_ENV_HOME/<name>/.pixi/envs/default`.

`pixi env activate` / `pixi-env activate` and `pixi env deactivate` / `pixi-env deactivate` require the shell integration because a subprocess cannot modify the parent shell environment directly.

On activation, `pixi-env` also sets conda-compatible environment variables (`CONDA_PREFIX`, `CONDA_DEFAULT_ENV`, `CONDA_PROMPT_MODIFIER`, `CONDA_SHLVL`) so prompt tools such as Starship can display the active environment.
