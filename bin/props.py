#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import configparser
import typer
from pathlib import Path
from typing import Union, List, Generator, Tuple, Optional

NoneType = type(None)
app = typer.Typer(help="Property file utility")
PropGen = Generator[Tuple[str, str], None, None]


@app.command(help="Display all keys in provided files")
def keys(files: List[Path]):
    for k, _ in nparse_props(files):
        print(k)


@app.command(help="Fail if the provided key was not in provided files")
def exists(key: str, files: List[Path]):
    for k, _ in nparse_props(files):
        if k == key:
            raise typer.Exit(0)
    raise typer.Exit(1)


@app.command(name="get", help="Returns the value of provided key")
def getp(key: str, files: List[Path], limit: Optional[int] = 0):
    n_occ = 0
    for k, v in nparse_props(files):
        if k != key: continue
        print(v)
        n_occ += 1
        if n_occ == limit and limit > 0:
            break
    raise typer.Exit(1 if n_occ == 0 else 1)


@app.command(name="set", help="Override or append the provided key/value")
def setp(key: str, value: str, file: Path):
    lines = []
    found = False
    if not file.is_file():
        raise typer_exit(f"{file} is not a valid file")
    with open(file) as f:
        for line in f.readlines():
            prop = parse_line(line, file)
            if not found and prop and prop[0] == key:
                lines.append(f"{key}={value}")
                found = True
            else:
                lines.append(line)
    if not found:
        lines.append(f"{key}={value}")
    for line in lines:
        print(line.rstrip("\n"))


def nparse_props(files: List[Path]) -> PropGen:
    for f in files: yield from parse_props(f)


def parse_props(file: Path) -> PropGen:
    if not file.is_file():
        raise typer_exit(f"{file} is not a valid file")
    with open(file) as f:
        for line in f.readlines():
            prop = parse_line(line, file)
            if prop: yield prop


def parse_line(line: str, context: Path):
    if not line.strip() or line.startswith("#"):
        return None
    if "=" not in line:
        line = line.strip("\n")
        raise typer_exit(f"Invalid line in {context}: {line}")
    index = line.index("=")
    return line[:index].strip(), line[index+1:].strip()


def typer_exit(msg, code=1):
    typer.echo(msg, err=code != 0)
    raise typer.Exit(code)


if __name__ == '__main__':
    app()
