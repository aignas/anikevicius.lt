+++
title = "git-prompt-rs: diagnostics and logging"
date = 2018-11-10

[taxonomies]
tags = ["rust", "git", "prompt"]
categories = ["Programming"]
+++

This post is from a series of posts about writing a small application in Rust to display information about a particular git repository.
- [Part 1: Writing MVP][part-01]

Yesterday I finished with a reasonably good starting point and I thought that
I would not talk about diagnostics, but after finding out how good `rust`
tool-chain is at this, I wanted to share some thoughts.

<!-- more -->

Yes, some simple CLIs like ours probably don't need an option to do heavy
diagnostics on it.  However, when we do run into problems and don't have a good
way to introspect your programs, I am going to waste more time than I want.
That is why it makes sense to start doing it as early as possible.

# Macros to the rescue

Using the tips from [rust cookbook][rust-book-logging] one can get started really quickly.
Add the following to the dependency section in your `Cargo.toml`:
```toml
log = "0.4"
env_logger = "0.5"
```
and run:
```
$ cargo update
```
Then follow the instructions to get the `env_logger` set up.

Then you can enable debug logging for your own program by simply running like:
```
$ RUST_LOG=git_prompt cargo run -- ${YOUR_PATH_TO_GIT_REPO}
```

If you want all logs, including other packages, you can do this by:
```
$ RUST_LOG=debug cargo run -- ${YOUR_PATH_TO_GIT_REPO}
```

This gives you all the logs from all the packages and the compiler.  This can be really useful tricky situations, which I am probably not going to encounter here, but it will definitely useful in the future.

Things I really like:
- `debug!` and other related macros can do really clever stuff in order to
  limit the impact of the logging.
- standard way to do logging through macros.
- not requiring to do dependency injection for logging.  It is a cross-cutting
  concern and as a result it may pollute your object factory functions.

Continue to:
- [Part 3: generating test data][part-03]
- [Part 4: type driven rewrite][part-04]

[part-01]: @/blog/git_prompt_01/index.md
[part-02]: @/blog/git_prompt_02/index.md
[part-03]: @/blog/git_prompt_03/index.md
[part-04]: @/blog/git_prompt_04/index.md
[rust-book-logging]: https://rust-lang-nursery.github.io/rust-cookbook/development_tools/debugging/log.html
