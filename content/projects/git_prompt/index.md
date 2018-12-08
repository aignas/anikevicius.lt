+++
title = "git_prompt"
description = "A CLI to provide git repository information for your prompt."
date = 2018-12-10

template = "project.html"

[taxonomies]
tags = ["rust", "git", "prompt"]

[extra]
img = "https://asciinema.org/a/RlvQkQ57HZ6Pcw7pNlvuLAfjd.svg"
img_alt = "git_prompt screencast"
+++

As a way to learn [Rust](https://www.rust-lang.org/) I decided to write a small
git prompt.  I use it everyday myself and I strive it to be an example of how
fast something like this can be.

## Goals

- Fast: Rust's excellent benchmarking tooling helps with that.
- Read-only: Rust's immutable by default helps me to create a read-only interface to the git-repository.
- Cross-platform: Currently tested on Mac and Linux.
- Shell agnostic: It's a binary it runs everywhere.

## Features

- When counting the commit difference between the remote and the local clone it
  will default to the `master` on the remote if a branch with the same name is
  not found.  The default is customizable.

- It will make sure that the last character of the prompt is a space.  Some
  shells break because of this.

## Screencast

<a href="https://asciinema.org/a/RlvQkQ57HZ6Pcw7pNlvuLAfjd" target="_blank"><img src="https://asciinema.org/a/RlvQkQ57HZ6Pcw7pNlvuLAfjd.svg" width="600"/></a>
