#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import curses
import subprocess
import typer
from os.path import expanduser
from pathlib import Path
from typing import Union, List, Generator, Tuple, Optional


def aidea(project_dir: Optional[Path] = typer.Argument(None)):
    """
    Interactively ask which IDEA path to use to open a project,
    or display detected installations if no path is provided.

    See https://github.com/pgreze/dotfiles/issues/4 for inspirations.
    """
    if not project_dir:
        for install_path, launcher in resolve_install_paths():
            print(install_path)
        raise typer.Exit(0)

    paths = list(resolve_install_paths())
    if not paths:
        print("No installations found", file=sys.stderr)
        raise typer.Exit(1)

    for index, (path, _) in enumerate(paths):
        index = str(index + 1).rjust(len(paths), " ")
        print(f"{index}: {path}")
    selected_launcher = None
    while not selected_launcher:
        print("Which installation to use? ", end="")
        try:
            index = int(input()) - 1
            if index >= 0 and index < len(paths):
                selected_launcher = paths[index][1]
        except Exception: # Filter all errors except ctrl+c
            continue

    proc = subprocess.run(["/usr/bin/open", "-na", selected_launcher, "--args", project_dir.absolute()])
    raise typer.Exit(proc.returncode)


def resolve_install_paths():
    # Jetbrains Toolbox
    toolbox_root_dir = Path(expanduser("~/Library/Application Support/JetBrains/Toolbox/apps"))
    yield from _resolve_toolbox_launchers(toolbox_root_dir / "AndroidStudio", "studio")
    yield from _resolve_toolbox_launchers(toolbox_root_dir / "IDEA-C", "idea")
    # Manual installations
    for d in Path("/Applications/").iterdir():
        # brew install intellij-idea intellij-idea-ce
        if d.name.startswith("IntelliJ IDEA") and d.name.endswith(".app"):
            yield from _resolve_launcher(d, "idea")
        # brew install android-studio android-studio-preview-beta android-studio-preview-canary
        if d.name.startswith("Android Studio") and d.name.endswith(".app"):
            yield from _resolve_launcher(d, "studio")


# Resolve .../IDEA-C -> ch-0 -> 202.7660.26 -> IntelliJ IDEA CE.app -> Contents/MacOS/idea
def _resolve_toolbox_launchers(root_dir: Path, filename: str):
    #if not root_dir.is_dir(): return
    for d1 in root_dir.iterdir(): # ch-0
        if not d1.is_dir(): continue
        for d2 in d1.iterdir(): # 202.7660.26
            if not d2.is_dir(): continue
            for d3 in d2.iterdir(): # IntelliJ IDEA CE.app
                yield from _resolve_launcher(d3, filename)


def _resolve_launcher(install_dir: Path, filename: str):
    if not install_dir.is_dir(): return
    launcher = install_dir / "Contents/MacOS" / filename
    if launcher.exists(): yield (install_dir, launcher,)


if __name__ == "__main__":
    typer.run(aidea)
