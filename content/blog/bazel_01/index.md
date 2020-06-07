+++
title = "bazel repo: Starting a monorepo"
date = 2020-06-07

[taxonomies]
tags = ["bazel", "git", "go"]
categories = ["Programming", "Monorepo"]
+++

I love monorepos and it was not the case prevously but I do think that monorepos shine in scenarios where:
* The code is tightly coupled together.
* One needs to ensure that resources on dev-tooling are efficiently spent.
* Migrations can be completed atomically.

Bazel is a really good build system, which allows reproducible and reasonably
fast builds and the build system is configured with starlark, which can be used
to write custom build rules, which allow to do linting or ensure consistency in
packaging, etc.

<!-- more -->

I use `bazel` at work and I do not want to have to remember how to use two
build systems or build my `make` targets and maintain them across multiple
repositories.  For this reason I decide to attempt to create a monorepo for
myself, which would leverage `bazel` to:
* Write in multiple languages:
  * Rust
  * Go
  * Shell
* Have common packaging for all.
* Have reproducible builds and leverage caching in between the builds.

In a few hours I could complete a repository setup, which:
* Uses `direnv` to setup dev environment.
* Uses `bazelisk` to download the predefined `bazel` version.
* Setup a custom `shellcheck` rule which lints all files with `.sh` extension in my `tools` directory.
* Setup `gazelle` for upcoming go code.
* Setup `buldifier` to ensure that my `BUILD.bazel` files are formatted.
* Setup a CI script to ensure that my repository is clean.

See it at [aignas/c](https://github.com/aignas/c).

Future ideas:
* Setup Travis CI or GitHub actions.
* A toy `go` CLI to iron out wrinkles in the `gazelle` and CI setup.
* A toy `rust` CLI to try out `cargo-raze`.
* Add tests for my `shell` scripts to test out `sh_test` rules.
* Generalize the `shellcheck` `bazel` rule and put it into a separate repository.
* Write a `shfmt` rule.
* `bazel` packaging rule for ArchLinux.
* Make the setup work on all OSes:
  * The `bazelisk` bootstrap script should check the OS before downloading `bazelisk` binary.
  * `shellcheck` rule should detect the OS and download the appropriate `shellcheck` binary for the host architecture.

Disclaimer: whilst I do intend to continue experimenting with this and post future updates here, I have other hobbies and it may take some time before I advance this experiment further.
