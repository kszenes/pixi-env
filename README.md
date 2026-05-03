# pixi-global-env (`pg`)

`pg` is a small wrapper that lets you use [pixi](https://pixi.sh) projects like global conda-style environments.

All environments are stored under one directory:

- default: `~/.pixi-global-envs`
- override: set `PG_HOME=/some/directory`

## Install

Put `bin/pg` on your `PATH`, for example:

```sh
mkdir -p ~/.local/bin
cp bin/pg ~/.local/bin/pg
```

Then enable activation/deactivation in your shell (`bash` or `zsh`):

```sh
eval "$(pg shell-init)"
```

Add that line to `~/.bashrc` or `~/.zshrc` to make it permanent.

## Usage

```sh
pg create py311 python=3.11 numpy
pg ls
pg a py311
python --version
pg d
```

More commands:

```sh
pg list      # or: pg ls
pg activate py311  # or: pg a py311
pg deactivate      # or: pg d
pg add pandas matplotlib      # adds to active env
pg add py311 pandas matplotlib # explicit env
pg run py311 -- python -c 'import numpy; print(numpy.__version__)'
pg path          # prints the env root directory
pg path py311    # prints one env directory
pg remove py311
```

## Notes

Each global environment is a normal pixi project stored at `$PG_HOME/<name>`. Its default environment prefix is `$PG_HOME/<name>/.pixi/envs/default`.

`pg activate` and `pg deactivate` require the shell integration because a subprocess cannot modify the parent shell environment directly.

On activation, `pg` also sets conda-compatible environment variables (`CONDA_PREFIX`, `CONDA_DEFAULT_ENV`, `CONDA_PROMPT_MODIFIER`, `CONDA_SHLVL`) so prompt tools such as Starship can display the active environment.
