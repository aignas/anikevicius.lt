+++
title = "git-prompt-rs: Generating test data for UI tuning"
date = 2018-11-11

[taxonomies]
tags = ["rust", "git", "prompt"]
categories = ["Programming"]
+++

This post is from a series of posts about writing a small application in Rust to display information about a particular git repository.

- [Part 1: Writing MVP][part-01]
- [Part 2: Logging][part-02]

I have finished at the MVP stage (part 1) of the prompt after adding the logging (part 2) so in this post I summarize the rest of features:
- `git` branch status
- `git` local status

<!-- more -->

# Git local status

At the moment we have a simple program that can print a branch name into the
`stdout`.  It does provide some information, but it is nowhere near the desired
outcome.

If we look again at the example I have given in [part 1][part-1] of the series, we have information about the current repo index status, such as:
- number of changed tracked files
- number of untracked files
- number of files that need merging

![zsh-git-prompt-example][od-prompt-img]

These are quite useful things to know when one is working on a project stored
in `git` and that is what we are going to implement next.

I have done some refactoring since the last time and the overall program now
looks as follows:
```rust
// .. imports

type R<T> = Result<T, String>;

fn main() {
    // .. parsing of the CLI arguments

    let output = get_output(path);
    debug!("Result: {:?}", output);
    print!("{} ", output.unwrap_or(String::new()))
}

fn get_output(path: &str) -> R<String> {
    let repo = Repository::discover(path).or(Err("no repo found"))?;
    Ok(format!("{}", get_branch_name(&repo)?))
}

fn get_branch_name(repo: &Repository) -> R<String> {
    let head = repo.head().or(Err("failed to get HEAD"))?;
    Ok(head.shorthand().unwrap_or("unknown").to_owned())
}

```

The idea is to encapsulate all of the logic of constructing the status in one
function and main is only responsible for the interaction with the outside
world.

# Some notes on the data

It is important to note, that when we receive the status of the files in the
git repository, each item in the list may have multiple flags associated to it.
For example, we could have staged the changes in a particular file (e.g.
`main.rs`) and then modified it and then I would expect the status to show,
that there is one staged file and one file that has modifications.  That is why
we should not think that the sum of all changed items in the status list is the
sum of items that have been changed.

I am going to take some inspiration from Olivier and define them as:
- `✔ ` repository is clean
- `●n` there are n files that have staged changes
- `○n` there are n files that have unstaged changes
- `✗n` there are n files that have unmerged changes
- `+n` there are n files that are untracked

The implementation is not one of the most succinct, so I'll spare you from
having all of it inline, especially since I have outline the main things how it
is going to be structured.

# Branch status

I still need to implement some way to have branch status and after some thinking I decided to go with the following approach:
- As a user I want to see differences between the remote branch in `origin`.
- If there is no upstream branch in `origin`, do the comparison with the `origin/master`.
- If I am cherry-picking, rebasing, merging, print one of instead:
    - `cherry-pick`
    - `rebase`
    - `merge`

Thus the result should look as:
```
<branch> <branch-status> <local-status>
```

Let's use the [repository state][docs-git2-repo-state] and implement the last
part of the list by creating a function which maps the state to a string:
```rust
// ...
    let state = match repo.state() {
        git2::RepositoryState::Merge => Some("merge"),
        git2::RepositoryState::Rebase
        | git2::RepositoryState::RebaseInteractive
        | git2::RepositoryState::RebaseMerge => Some("rebase"),
        git2::RepositoryState::RevertSequence => Some("revert"),
        git2::RepositoryState::CherryPick | git2::RepositoryState::CherryPickSequence => {
            Some("cherry-pick")
        }
        _ => None,
    };

    if let Some(s) = state {
        return Ok(format!(" {}", s));
    }
// ...
```

As you see, we want to return the state of the branch, if we are doing
something *special* on not do anything else.  The only odd thing about this is
that `rustfmt` is formatting the code in an interesting way for the
`cherry-pick` case, but I can live with this.

# Colours

Up until now everything was white on black on my terminal.  This means that it
may require more time to quickly notice the state of the git repo.  That is why
I decided to use the [colored crate][colored-crate], which makes it very easy
to define color schemes by using simple names of the colours.  I also hope to
expose this as a configuration parameters for the user.

However, fine-tuning of the defaults may require some tinkering and that is why
I decided to write some helper routines, which would print me some examples.
For that I implemented a naïve random data generator using
[rng::choose][rng-crate].  The final test can be seen below:

![final test][final-test]

This is really useful to test happy paths and see how things look like with
various data.

Continue to:
- [Part 4: type driven rewrite][part-04]

[part-01]: @/blog/git_prompt_01/index.md
[part-02]: @/blog/git_prompt_02/index.md
[part-03]: @/blog/git_prompt_03/index.md
[part-04]: @/blog/git_prompt_04/index.md

[docs-git2-repo-state]: https://docs.rs/git2/0.7.5/git2/enum.RepositoryState.html
[colored-crate]: https://github.com/mackwic/colored
[rng-crate]: https://docs.rs/rand/0.5.3/rand/trait.Rng.html#method.choose

[od-prompt-img]: od-prompt-img.png
[final-test]: test.png
