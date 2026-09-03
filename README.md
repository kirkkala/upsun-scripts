# upsun-scripts

Small CLI helpers for working with [Upsun](https://upsun.com/) projects.

## upsun-db-dump

Dump database for the **current git branch environment** into a dated SQL file.

### Install

```bash
./install.sh
```

The command is installed to `/usr/local/bin/upsun-db-dump`. After that you can run it from any Upsun project repo with

```bash
upsun-db-dump
```

### What it does

Runs `upsun db:dump` for the environment that matches your current git branch, and writes:

```text
YYYY-MM-DD-HHMM-<project>-<branch>.sql
```

into:

- `<repo>/drupal/db_dumps/` if that directory already exists
- `<repo>/db_dumps/` otherwise (created if needed)

### Requirements

- macOS or Linux
- [git](https://git-scm.com/)
- [Upsun CLI](https://docs.upsun.com/administration/cli/) (`upsun`)
- A local clone of an Upsun project (run the command from inside it)

### Uninstall

```bash
cd /path/to/upsun-scripts
./uninstall.sh
```
