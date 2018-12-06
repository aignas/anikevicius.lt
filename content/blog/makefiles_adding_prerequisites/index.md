+++
title = "Makefile: adding prerequisites to external targets"
date = 2018-12-06

[taxonomies]
tags = ["make", "rules", "recipe", "prerequisites"]
+++

Consider that you have a situation where you have a build system using `make`
heavily.  And you want to hook into one of the targets such that before the
target is built, `make` builds the prerequisite you are interested in.

<!-- more -->

The following `Makefile` illustrates what we have at hand:
```makefile
api: dep
	@echo "-- building API --"

dep:
	@echo "-- building dep --"

#######################################
# The above is defined somewhere else #
#######################################

# My rules
```

Using the make file yields us:
```
$ make api
-- building dep --
-- building API --
```

Now what we want is to build docs before `dep` is built.
It turns out that this can be achieved simply by adding the following to your `Makefile`:

```makefile
dep: docs
docs:
	@echo "-- building docs --"
```

Then when we execute the same command, we get:
```
$ make api
-- building docs --
-- building dep --
-- building API --
```

This technique can be really useful to add prerequisites for targets without
modifying them.
