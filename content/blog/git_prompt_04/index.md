+++
title = "git-prompt-rs: Type driven development in Rust"
date = 2018-11-25

[taxonomies]
tags = ["rust", "git", "prompt"]
categories = ["Programming"]
+++

This post is from a series of posts about writing a small application in Rust
to display information about a particular git repository.

- [Part 1: Writing MVP][part-01]
- [Part 2: Logging][part-02]
- [Part 3: Testing the UI and color schemes][part-03]

In this part I try to explore the problem by relying on the Rust's compiler and
the sum types.

<!-- more -->

# Rewriting, the type-driven way.

I am really happy with what I have learned during this exploration of the rust
language and I think that it is has been a really nice journey.  However, there
was one more thing which I wanted to try out, which I did not manage to do with
the previous version of the CLI.

Type driven development is only really possible when there are no `NULL` values
and you can explore how the types/possible failure states constrain the high
level structure of the domain logic of your program.  With functional languages like `F#` or `Haskell` you can leverage the fact that the types can be inferred automatically, but with Rust one can start testing out how to work with the following developing flow:

- Investigate the structure via the type system (e.g. `Result`, `Option`).
- Implement the minimum happy paths.
- Stabilize the implementations by adding unit tests.

I have recently started working with `go` in my day-to-day programming at work and I realized
that one could also start reusing concepts like:

- Accept interfaces, return structs.
- Use the trait system to make external structs implement the locally defined traits.

All of the things mentioned above means that I could write the whole program in
a slightly different manner than before.  You can find the code on [github][link].

# Type driven

What I like the most about rust is the sum-types and how they change the way
one needs to think about the domain.  The fact that you get `Option<T>` or
`Result<T, E>` from a particular function means that you will need to do some
error handling or potentially think about how to recover at the place where the
error occurs if you do not want to propagate the `Result` type up the stack.
The similar is true for `go` as well, which helps one to write relatively
stable code early on.

However, where this really shines is when you start modelling your program as a
motion of data.  At the end of the day the whole CLI design is all about the
data.  This means that researching the domain of the problem with data
structures where one passes them around is a reasonably natural thing to do.
This has the following implications:

- One can decouple the software from the parts of the code which interact with
  the outside world.

- One can more easily bundle the data that needs to be moved together, which
  makes the interaction of different code pieces much easier.

# Discoveries

There were some interesting discoveries along the way and the most important
realisation was the fact that the whole application becomes much easier to test
the functional Model-View architecture is being used.  Since this is not a
long-running application, there is no need to think how the application is
going to be updated, but the potential for generalisation is there.

Testing was another thing that surprised me.  I have a lot of
scientific/engineering related background and the code that one writes there
most of the times deals with data transformations involving complex algorithms
and mathematical formulae.  The data input into the system most of the times
constitutes only a small part of the system.

However, when one deals with querying of stateful systems and the part that
matters is the representation of the data in those stateful systems, the hard
part becomes either the UI, or the queries of the stateful systems and not as
much the data transformations.  This means that creating a seam early on to not
rely on mocks to test the system is really good.

[part-01]: ./blog/git_prompt_01/index.md
[part-02]: ./blog/git_prompt_02/index.md
[part-03]: ./blog/git_prompt_03/index.md
[part-04]: ./blog/git_prompt_04/index.md
[link]: https://github.com/aignas/git-prompt-rs
