[![CI](https://github.com/bkuolt/papa-noel/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/bkuolt/papa-noel/actions/workflows/test.yml)

## About
*Papá Noel* (Spanish for Santa Claus) is a prototype of a simple 2D platformer game built using LÖVE2D.

![Screenshot](screenshot.png)

## Installation

Download the source code and install [LÖVE2D](https://love2d.org):

```bash
git clone https://github.com/bkuolt/papa-noel.git
cd papa-noel
task install-deps
```

*Alternatively, run `./install.sh` directly.*

## Controls & Usage

Run the game via Taskfile:
```bash
task run
```
*Alternatively, run `./papa-noel` directly.*

| Key | Function |
| --- | --- |
| `Esc` | Exit game |
| `P` | Pause / resume game |
| `B` | Show / hide bounding boxes |
| `Space` | Enable / disable level editor mode |