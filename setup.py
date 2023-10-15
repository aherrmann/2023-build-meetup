#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess


BRANCHES = [
        "00-bazel-worker",
        "01-bazel-get-started",
        "01-buck2-get-started",
        "02-bazel-minimal",
        "02-buck2-minimal",
        "03-bazel-basic",
        "03-buck2-basic",
        "04-bazel-isolation",
        "04-buck2-isolation",
        "05-bazel-rbe",
        "05-buck2-rbe",
        "06-bazel-incremental",
        "06-buck2-incremental"]


APT_PACKAGES = [
        "build-essential",
        "clang",
        "ghc",
        "git",
        "libffi-dev",
        "libgmp-dev",
        "libtinfo5",
        "libtinfo-dev",
        "lld",
        "openjdk-11-jdk",
        "python3",
        "zstd"]


BAZELISK_URL="https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64"

SETUP_COMMANDS = [
        # Apt install
        "sudo apt-get update",
        "sudo apt-get install --yes " + " ".join(APT_PACKAGES),
        # Install Bazelisk
        "bazelisk_out=$(mktemp)",
        f"curl -L {BAZELISK_URL} -o $bazelisk_out",
        "chmod +x $bazelisk_out",
        "echo Install Bazel",
        "sudo mv $bazelisk_out /usr/local/bin/bazel",
        # Install rustup & Buck2 on first login
        "echo \"[ -d \\$HOME/.cargo ] || { curl https://sh.rustup.rs -sSf | sh -s -- -y; source \\$HOME/.cargo/env; }\" >> $HOME/.profile",
        "echo \"[ -f \\$HOME/.cargo/env ] && . \\$HOME/.cargo/env\" >> $HOME/.profile",
        "echo \"[ -x \\$HOME/.cargo/bin/buck2 ] || { rustup install nightly-2023-07-10; cargo +nightly-2023-07-10 install --git https://github.com/facebook/buck2.git buck2; }\" >> $HOME/.profile",
        "echo \"[ -d \\$HOME/.ghcup ] || { curl --proto =https --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=latest BOOTSTRAP_HASKELL_CABAL_VERSION=latest BOOTSTRAP_HASKELL_INSTALL_STACK=1 BOOTSTRAP_HASKELL_INSTALL_HLS=1 BOOTSTRAP_HASKELL_ADJUST_BASHRC=P sh; }\" >> $HOME/.profile",
        "echo \"[ -f \\$HOME/.ghcup/env ] && . \\$HOME/.ghcup/env\" >> $HOME/.profile",
        "echo \"[ -x \\$HOME/.ghcup/bin/ghc ] || { ghcup install ghc 9.8.1; ghcup set ghc 9.8.1; source \\$HOME/.ghcup/env; }\" >> $HOME/.profile",
        ]


def is_distrobox_installed():
    return shutil.which("distrobox") is not None


def create_distrobox(name, workdir):
    result = subprocess.run(
            [
                "distrobox", "create",
                "--yes",
                "--image", "ubuntu:22.04",
                "--name", name,
                "--home", os.path.abspath(workdir),
                "--init-hooks", " && ".join(SETUP_COMMANDS)],
            capture_output=True, text=True)

    if result.returncode != 0:
        raise Exception(f"Failed to create distrobox container. Error: {result.stderr}")

    print(f"To enter the distrobox container run\n\n    distrobox enter {name}")

    return result.stdout


def initialize_submodules_if_present(path):
    gitmodules_path = os.path.join(path, '.gitmodules')

    if os.path.exists(gitmodules_path):
        result = subprocess.run(
                ["git", "submodule", "update", "--init", "--recursive"],
                capture_output=True,
                text=True,
                cwd=path)

        if result.returncode != 0:
            raise Exception(f"Failed to initialize git submodules. Error: {result.stderr}")

        return True

    return False


def create_workdir(path):
    if os.path.exists(path):
        raise FileExistsError(f"The directory '{path}' already exists.")

    os.mkdir(path)


def recursive_remove_directory(path):
    if os.path.exists(path):
        shutil.rmtree(path)


def create_git_worktree(prefix, branch_name):
    target_path = os.path.join(prefix, branch_name)

    if os.path.exists(target_path):
        raise FileExistsError(f"The directory '{target_path}' already exists.")

    result = subprocess.run(["git", "worktree", "add", target_path, branch_name], capture_output=True, text=True)

    if result.returncode != 0:
        raise Exception(f"Failed to create git worktree. Error: {result.stderr}")

    initialize_submodules_if_present(target_path)

    return target_path


def prune_git_worktree():
    result = subprocess.run(["git", "worktree", "prune"], capture_output=True, text=True)

    if result.returncode != 0:
        raise Exception(f"Failed to prune git worktree. Error: {result.stderr}")

    return result.stdout


def main():
    parser = argparse.ArgumentParser(
            prog="2023-build-meetup-setup",
            description="Set up the demo environment for the Buck2/Bazel talk at Build Meetup 2023.")
    parser.add_argument(
            "workdir",
            type=str,
            help="The working directory to use.")
    parser.add_argument(
            "--distrobox",
            action="store_true",
            help="Create a distrobox container to work in.")
    parser.add_argument(
            "--prune",
            action="store_true",
            help="Remove any previously existing working directory.")
    args = parser.parse_args()

    if args.prune:
        recursive_remove_directory(args.workdir)
        prune_git_worktree()

    create_workdir(args.workdir)

    if args.distrobox:
        assert is_distrobox_installed(), "distrobox must be installed"
        create_distrobox("2023-build-meetup", args.workdir)

    for branch in BRANCHES:
        create_git_worktree(args.workdir, branch)


if __name__ == "__main__":
    main()
