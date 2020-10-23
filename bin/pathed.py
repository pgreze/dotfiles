#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import os.path
import sys
import typer
from typing import List

paths = lambda: (v.rstrip("/") for v in os.environ["PATH"].split(":"))
app = typer.Typer(help="""PATH editor utility.

Expected usages:

if {cli} exists /usr/local/bin; then TODO; fi

export PATH="$({cli} add /usr/local/bin --unique)"
""".format(cli=os.path.basename(sys.argv[0])))


@app.command(name="list", help="Display all entries in PATH")
def ls():
    for p in paths(): print(p)


@app.command(help="Fail any provided value is not in PATH")
def exists(values: List[str]):
    raise typer.Exit(len(set(v.rstrip("/") for v in values) - set(paths())))


@app.command(name="add", help="Add to the top of PATH provided values, and remove duplicates if asked")
def add(
    values: List[str],
    unique: bool = typer.Option(False, help = "Delete duplicates of provided values if found")
):
    values = [v.rstrip("/") for v in values]
    print(":".join(values + [v for v in paths() if v not in value or not unique]))


@app.command(name="del", help="Deletes all occurences of the provided values in PATH")
def delete(values: List[str]):
    values = [v.rstrip("/") for v in values]
    print(":".join(v for v in paths() if v not in values))


if __name__ == '__main__':
    app()
