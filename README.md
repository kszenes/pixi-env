# pixi-global-env (`pg`)

`pg` is a small wrapper that lets you use [pixi](https://pixi.sh) projects like global conda-style environments.

All environments are stored under one directory:

- default: `~/.pixi-global-envs`
- override: set `PG_HOME=/some/directory`

## Install

Install with:

```sh
curl -LsSf https://raw.githubusercontent.com/kszenes/pixi-global-env/main/install.sh | sh
```

Or from a local checkout:

```sh
./install.sh
```

The installer supports Linux and macOS. If `pixi` is not installed, it installs pixi with:

```sh
curl -fsSL https://pixi.sh/install.sh | sh
```

The installer copies `pg` to `~/.local/bin/pg` by default. Override with:

```sh
PG_INSTALL_DIR=/usr/local/bin ./install.sh
```

Then enable activation/deactivation in your shell (`bash` or `zsh`):

```sh
eval "$(pg shell-init)"
```

Add that line to `~/.bashrc` or `~/.zshrc` to make it permanent.

## Usage

```sh
pg create -n py311 python=3.11 numpy
pg list
pg activate -n py311
python --version
pg deactivate
```

More commands:

```sh
pg list
pg activate -n py311
pg deactivate
pg add pandas matplotlib          # adds to active env
pg add -n py311 pandas matplotlib # explicit env
pg run -n py311 -- python -c 'import numpy; print(numpy.__version__)'
pg path           # prints the env root directory
pg path -n py311  # prints one env directory
pg remove -n py311
```

## Notes

Each global environment is a normal pixi project stored at `$PG_HOME/<name>`. Its default environment prefix is `$PG_HOME/<name>/.pixi/envs/default`.

`pg activate` and `pg deactivate` require the shell integration because a subprocess cannot modify the parent shell environment directly.

On activation, `pg` also sets conda-compatible environment variables (`CONDA_PREFIX`, `CONDA_DEFAULT_ENV`, `CONDA_PROMPT_MODIFIER`, `CONDA_SHLVL`) so prompt tools such as Starship can display the active environment.
