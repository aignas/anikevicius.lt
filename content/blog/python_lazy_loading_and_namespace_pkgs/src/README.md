# Namespace packages work correctly

This is a test reproducing the behaviour of Apache airflow packages that
I have observed at dayjob. It seems that the `lazy-import` feature is
not working as intended if the package that is doing the lazy import is
not the first item in the `sys.path` list that `bazel` is constructing.

See [tests/BUILD.bazel](./tests/BUILD.bazel) for documentation of the test cases.
