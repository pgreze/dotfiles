#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import curses
import subprocess
import typer
from collections import namedtuple
from os.path import expanduser
from pathlib import Path
from typing import Union, List, Generator, Tuple, Optional


Install = namedtuple('Install', ['install_dir', 'launcher', 'infoString'])


def aidea(project_dir: Optional[Path] = typer.Argument(None)) -> typer.Exit:
    """
    Interactively ask which IDEA path to use to open a project,
    or display detected installations if no path is provided.

    See https://github.com/pgreze/dotfiles/issues/4 for inspirations.
    """
    sorted_installs = sorted(
        resolve_installs(),
        key=lambda i: i.install_dir,
        reverse=True
    )

    # Just display the paths if no project is provided.
    if not project_dir:
        for install in sorted_installs:
            print(install.install_dir)
        raise typer.Exit(0)

    installs = list(sorted_installs)
    if not installs:
        print("No installations found", file=sys.stderr)
        raise typer.Exit(1)

    for index, install in enumerate(installs):
        prefix = str(index + 1).rjust(3, " ")
        print(f"{prefix}: {install.infoString}")
        print(f'{" " * len(prefix)}  {install.install_dir}', end='\n\n')
    selected_launcher = None
    while not selected_launcher:
        print("Which installation to use? ", end="")
        try:
            index = int(input()) - 1
            if index >= 0 and index < len(installs):
                selected_launcher = installs[index].launcher
        except EOFError: # ctrl-d support
            return typer.Exit(0)
        except Exception: # Filter all errors except ctrl-c
            continue

    proc = subprocess.run(["/usr/bin/open", "-na", selected_launcher, "--args", project_dir.absolute()])
    raise typer.Exit(proc.returncode)


def resolve_installs():
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
    if not launcher.exists(): return

    infoString = None
    if infoPlist := install_dir / "Contents/Info.plist":
        with open(infoPlist) as f:
            foundKey = False
            for line in f:
                if foundKey:
                    bgn = len('<string>')
                    # Drop '. Copyright JetBrains s.r.o., (c) 2000-2022'
                    # End alternative was just to drop </string>.
                    end = -(len(line) - line.index('Copyright') + 2)
                    infoString = line.strip()[bgn:end]
                    break
                foundKey = line.strip() == '<key>CFBundleGetInfoString</key>'

    yield Install(install_dir, launcher, infoString)


if __name__ == "__main__":
    typer.run(aidea)
