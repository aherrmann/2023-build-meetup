This repository houses the example code to the talk "[Comparing Buck2 and
Bazel][slides]" at [Build Meetup 2023][build-meetup]. These examples assume
that you are running on a Linux x86_64 platform with all requirements
installed (build-essential, clang, rustup/cargo, ghcup/ghc, zstd, bazel, buck2,
and all [rules_haskell dependencies][rules_haskell-deps]).

The code for each section is held in its own branch:
- [01-bazel-get-started]
- [01-buck2-get-started]
- [02-bazel-minimal]
- [02-buck2-minimal]
- [03-bazel-basic]
- [03-buck2-basic]
- [04-bazel-isolation]
- [04-buck2-isolation]
- [05-buck2-rbe]
- [05-bazel-rbe]
- [06-bazel-incremental]
- [06-buck2-incremental]

Each branch includes a `test.sh` script listing the relevant commands to test
the example.

Additionally the branch [00-bazel-worker] holds a patched version of the Bazel
code base that includes a remote worker compatible with Buck2 for testing. The
branch includes a script `remote-worker.sh` that builds and starts the remote
worker.

You can use the included `setup.py` to checkout all the branches into git
worktrees and optionally install a distrobox with all requirements installed,
assuming that you have [distrobox] installed.

[slides]: https://docs.google.com/presentation/d/1Riz78osRw6Ut3iLUuozqSImHq7sh3vJcHJgOq-vNFY0/edit?usp=sharing
[build-meetup]: https://www.engflow.com/buildCommunityEvents
[rules_haskell-deps]: https://rules-haskell.readthedocs.io/en/latest/haskell.html#before-you-begin
[distrobox]: https://github.com/89luca89/distrobox

[00-bazel-worker]: https://github.com/aherrmann/2023-build-meetup/tree/00-bazel-worker
[01-bazel-get-started]: https://github.com/aherrmann/2023-build-meetup/tree/01-bazel-get-started
[01-buck2-get-started]: https://github.com/aherrmann/2023-build-meetup/tree/01-buck2-get-started
[02-bazel-minimal]: https://github.com/aherrmann/2023-build-meetup/tree/02-bazel-minimal
[02-buck2-minimal]: https://github.com/aherrmann/2023-build-meetup/tree/02-buck2-minimal
[03-bazel-basic]: https://github.com/aherrmann/2023-build-meetup/tree/03-bazel-basic
[03-buck2-basic]: https://github.com/aherrmann/2023-build-meetup/tree/03-buck2-basic
[04-bazel-isolation]: https://github.com/aherrmann/2023-build-meetup/tree/04-bazel-isolation
[04-buck2-isolation]: https://github.com/aherrmann/2023-build-meetup/tree/04-buck2-isolation
[05-buck2-rbe]: https://github.com/aherrmann/2023-build-meetup/tree/05-buck2-rbe
[05-bazel-rbe]: https://github.com/aherrmann/2023-build-meetup/tree/05-bazel-rbe
[06-bazel-incremental]: https://github.com/aherrmann/2023-build-meetup/tree/06-bazel-incremental
[06-buck2-incremental]: https://github.com/aherrmann/2023-build-meetup/tree/06-buck2-incremental
