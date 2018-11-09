# Writing yet another git prompt

As an attempt to learn Rust and type-driven development using it I am going
to show you how to write a small Rust CLI, which gives you status about the
current repository.  I wanted a small CLI to update my prompt for [ion][ion]
and [zsh][zsh] and I wanted it to be as fast as possible with the possibility
to extend in case I want to display more information.

For `zsh` there already is a nice solution made by Olivier Verdier [on github][od-prompt].

![zsh-git-prompt-example][od-prompt-img]

I think that it has a nice way of printing information and that is why I decided to use it as a starting point.

## Motivation

Why do I want to have such prompt written in Rust?  There are at least a few benefits from technical standpoint:
- It runs everywhere
- Everything is immutable by default, I don't want to change the repository, I only want to query it.
- I can easily parallelize certain bits, which means that it is faster.
- I can have tests and type safety.

## High level problem description

So this is a small program, which can be moddeled as below CLI interface if we wanted to pass all of the arguments to it as mixture of positional and optional arguments:
```
PROGRAM [<display options>] dir
```

Where the display switches may be:
- should it print a new line character at the end
- print error if it occurs or not
- read current directory from environment
- various switches which could toggle the amount of the information being printed:
    - current branch
    - ahead/behind count
    - git status summary
    - current repository state (e.g. merge, cherry-pick, rebase)

And the options, which may have values associated with them
- color-scheme specification

## MVP

In order for it to become useful straight away it needs to be able to:

* discover if we are currently in a git repository.
* if yes, print a human-readable form of the current revision.

Some cross-functional requirements:

* It might be nice if we can have some color for the branch.
* If we cannot find a git repo, we should exit straight away.
* We need to be able debug easily in case we have issues.
* It should never break `ion` or `zsh` shells.

The API we want to implement is:
```
PROGRAM [path]
```

### Tools

I am going to develop in my dotfiles repository, because I want the plugns to
be easy to install for me. Since everything will be contained in a single
folder, I will be able to export the git repository easily if needed later.

We start of by creating a `.gitignore`
```
# ignore build files
target/

# only store the definitions
Cargo.lock
```

And then we can create a new application using the excellent `rust` tool-chain:
```
$ mkdir git_prompt
$ cargo init --bin --edition 2018 git_prompt
$ cd git_prompt
```

Since I am coding with [neovim][nvim], I am going to define the following maps
in my vimrc:
```vim
augroup rust_settings
    autocmd!
    autocmd FileType rust let g:rustfmt_autosave = 1
    autocmd FileType rust nnoremap <leader>cr :!cargo run<cr>
    autocmd FileType rust nnoremap <leader>ct :!cargo test<cr>
    autocmd FileType rust nnoremap <leader>ct :!cargo bench<cr>
augroup END
```

This will help me to check the status often and iterate quickly.

Now `cargo run` should print `Hello, world!`, which means that we can continue.

### Code

We are going to use the excellent [git2][git2-crate] to interact with the
repository and it has a really nice API.

First, let's print path if it is passed in or print the current directory,
which we can get from the environment. If that fails we are going to use the
shorthand `"."` for the current directory.

```
use std::env;

fn main() {
    // get all arguments
    let args: Vec<String> = env::args().collect();

    // get the path as a first optional positional argument
    let path = args.get(1)
        .map(|p| p.to_string())         // do a copy
        .or(env::var("PWD").ok())       // try getting the path from PWD env var
        .unwrap_or(String::from("."));  // fallback to "."

    println!("Current path is: {:?}", path);
}
```
If we run `cargo run` it we get:
```sh
Current path is: "/home/ia/src/github/dotfiles/ion/plugins/git_prompt"
```

If we run `cargo run -- ${HOME}` it we get:
```sh
Current path is: "/home/ia"
```

However, I wanted to have a nice way to add parameters and the
[clap][clap-crate] crate seems to be a really nice way to do that, so the final
code looks slightly more complex, but more functional:

```rust
extern crate clap;
use clap::App;
use clap::Arg;


fn main() {
    let matches = App::new("git_prompt")
        .version("v0.1")
        .author("Ignas A. <anikevicius@gmail.com>")
        .about("Prints your git prompt info fast!")
        .arg(Arg::with_name("PATH")
             .help("Optional path to use for getting git info")
             .index(1)
             .default_value("."))
        .get_matches();

    println!("Using path: {}", matches.value_of("PATH").unwrap())
}
```

Next, we can extend the code so that it prints if we are in a git repo.
```rust
use git2::Repository;

// ...
    let path = matches.value_of("PATH").unwrap();
    if Repository::discover(path).is_ok() {
        println!("{} is in a git repo", path)
    } else {
        println!("{} is not in a git repo", path)
    }
}
```

Adding the following function finally completes the puzzle:
```rust
type R<T> = Result<T, String>;

// ...
fn get_branch_name(path: &str) -> R<String> {
    let repo = Repository::discover(path)
        .or(Err("failed to find a repo for the given path"))?;
    let head = repo
        .head()
        .or(Err("failed to get HEAD"))?;

    Ok(head
        .shorthand()
        .unwrap_or("unknown")
        .to_owned())
}
```

There is a final bit of making the diagnostics easier, which could be done by:
- setting an env var if a specific parameter is defined.
- creating a trait for our result type, which does logging when unwrapping.
- Using that for unwraps.

But that can be left as a practice for the reader.

*to be continued*

[ion]: https://github.com/redox/ion
[zsh]: https://ohmyz.sh/
[od-prompt]: https://github.com/olivierverdier/zsh-git-prompt "github repository"
[od-prompt-img]: https://github.com/olivierverdier/zsh-git-prompt/raw/master/screenshot.png "An example of Olivier`s prompt"
[nvim]: https://github.com/neovim/neovim
[git2-crate]: https://docs.rs/crate/git2/0.7.5
[clap-crate]: https://docs.rs/crate/clap/2.32.0
