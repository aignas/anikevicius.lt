+++
title = "Python lazy loading and namespace packages"
date = 2023-05-29

[taxonomies]
tags = ["python", "import", "bazel"]
categories = ["Python", "Bazel"]
+++

Recently I have bumped into a really weird issue, where in one project whilst
trying to use a package `pkg` (I'll use this name to avoid using a real project
name) and write tests using the `foo` backend, that lived in a different
package called `pkg_foo`. It was not working as intended when testing using the
`bazel` build system and this post is about the path to root-causing the issue
and arriving at the right conclusions.

TLDR: The source code with tests is in the [github.com/aignas/anikevicius.lt/][example].

<!-- more -->

# Python and it's lesser-known features

Recently I have learned about two Python features that may help with the dependency hell and I am going to set the context really quickly before moving on with the issue at hand.

* You can achieve lazy-loading of your modules by using a `__getattr__`
  function based on [PEP562].
* You can have a multiple packages constitute a single top-level module and use
  [pkgutil.extend_path] for telling Python how to make imports work. For
  example, the main package providing `pkg` and `pkg.main` can be extended by
  a `pkg_extension` package that adds `pkg.extension` and everything works
  magically.

# The common path

The common path which is exercised by most of the developers out there is that
the `pkg` and `pkg_foo` gets installed into the same `virtualenv` by the developer
and everything works as intended, because the `site-packages` directory in that `virtualenv`
would contain the following subtree:
```
site-packages/
  pkg
    __init__.py # contains the __getattr__ function to implement lazy loading
    main.py
  pkg_extension/
    __init__.py # contains pkgutil glue
    extension/ # contains contents of `pkg_extension` package
      ...
```

This means that both of the features will work correctly because the installed
Python package share the same file system layout and usually the
`pkg_extension` is usually visited after the `pkg` is visited when trying to
import things from the `pkg` package.

This means that the minimum working code example for the contents of `pkg/__init__.py` is:
```python
# Make `pkg` an namespace package.
__path__ = __import__("pkgutil").extend_path(__path__, __name__)  # type: ignore


__lazy_imports = {
    "foo": (".dir.lib", "foo"),
}


def __getattr__(name: str):
    # PEP-562: Lazy loaded attributes on python modules
    module_path, attr_name = __lazy_imports.get(name, ("", ""))

    if not module_path:
        raise AttributeError(f"module {__name__!r} has no attribute {name!r}")

    import importlib

    mod = importlib.import_module(module_path, __name__)
    if attr_name:
        val = getattr(mod, attr_name)
    else:
        val = mod

    # Store for next time
    globals()[name] = val
    return val

# We may include extra things below
```

And the `pkg_extension/__init__.py` only needs the hooks for the `pkgutil`:
```python
__path__ = __import__("pkgutil").extend_path(__path__, __name__)  # type: ignore
```

# When things may go wrong

In a simple virtual env, everything works as expected all of the time as the
directory traversal is deterministic (citation needed) and we usually hit the
`__init__.py` file from the `pkg` before the one from `pkg_extension`.
We were also careful to name our extensions with easy to find naming scheme and
everything works until we start using a build tool that has a different Python
package layout from the one expected by us.

When using `bazel` the `sys.path` order is determined by your build dependency
DAG (Directed Acyclic Graph), and the order of the packages appearing in the
`sys.path` is not lexicographically sorted (as of 6.2.0 at least). This means
that we may have the `pkg_extension` before the `pkg` in our `sys.path` which
will make it to be visited by the Python import machinery before the
`pkg/__init__.py` which has the lazy-loading magic.

To test this behaviour I have created a few tests in the [example] folder and
decided to go down the rabbit hole. Below is a list of combinations that I
have tested:

## `pkg` and `pkg_extension` names

This is working as intended if the `pkg` appears before `pkg_extension` in the `sys.path`.
If we reverse the order of their entries in the `sys.path`, then the lazy-loaded functions
and the regular function from `__init__.py` from the `pkg` package is failing.

## `pkg` and `extension_pkg` names

This is working in the same way, as the previous case, the `pkg` needs to be
before the `extension_pkg` in the `sys.path`.

## Copy the lazy loading machinery to the `extension_pkg_correct` and use that

So what the two data points are telling us is that the `lazy-loading` ceases to function
when the first thing that gets visited is the `__init__.py` file without the PEP562 hooks.
So if we copy the PEP562 hooks to the extension file, what happens then?

This, as expected makes the lazy loading work, because the lazy loading works by specifying the absolute import path as such:
```python
# __path__ manipulation added by bazelbuild/rules_python to support namespace pkgs.
__path__ = __import__("pkgutil").extend_path(__path__, __name__)


__lazy_imports = {
    "foo": ("pkg.dir.lib", "foo"),
}


def __getattr__(name: str):
    # PEP-562: Lazy loaded attributes on python modules
    module_path, attr_name = __lazy_imports.get(name, ("", ""))

    if not module_path:
        raise AttributeError(f"module {__name__!r} has no attribute {name!r}")

    import importlib

    mod = importlib.import_module(module_path, __name__)
    if attr_name:
        val = getattr(mod, attr_name)
    else:
        val = mod

    # Store for next time
    globals()[name] = val
    return val
```

Notice, the contents of `__lazy_imports`, which now has the absolute import
paths rather than relative ones as in the first snippet.

However it seems that we cannot import the function `fizz` that happens to be
in the `pkg/__init__.py` at the end of the file in the main package.

# Conclusion

It seems that having lazy imports using [PEP562] and supporting
[pkgutil.extend_path] usage to split the package into multiple parts does not
together. It may seem somewhat weird if one wants to do that, because if you
can depend on the lazy-import machinery, maybe you don't need to split your
packages anymore. On the other hand, everything works as expected if you have
only a single `site-packages` location where you install your packages, which
is almost always the case for regular Python users or Python installations
inside containers.

[example]: https://github.com/aignas/anikevicius.lt/tree/master/content/blog/python_lazy_loading_and_namespace_pkgs/src
[PEP562]: https://peps.python.org/pep-0562/
[pkgutil.extend_path]: https://docs.python.org/3/library/pkgutil.html#pkgutil.extend_path
