# Building
> [!NOTE]
> KatOS is a work-in-progress and such, these build instructions are also WIP.

Thank you for your interest in contributing to KatOS! While most Debian-based OSes should be able to build KatOS, the best OS for building KatOS is, well, KatOS! Ubuntu is reliable as well, though.

## 1. Dependencies
We use many dependencies to build KatOS, as it makes my job a lot easier. Run `sudo apt install debootstrap xorriso genisoimage schroot wget tar mount rsync` to get all the dependencies.

## 2. Run the build file
KatOS' build process is entirely automated, making it super easy to reproduce (and run inside our GitHub Workflow). In your terminal, run `cd src && ./build-katos.sh` and it should just work!