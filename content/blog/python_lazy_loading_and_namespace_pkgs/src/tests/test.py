import os
import sys
import unittest


def _print_sys_path():
    execroot, _, _ = sys.path[-1].partition("execroot")
    print(f"Execroot is: {execroot}")
    for p in sys.path:
        if "execroot" in p:
            _, _, p = p.partition("execroot/")
            print(f"    ...{{execroot}}/'{p}'")
        else:
            print(f"    '{p}'")

def _sort_runfiles(sys_path):
    sort_start = len(sys_path)
    sort_end = 0
    for i, p in enumerate(sys_path):
        if ".runfiles" not in p:
            print(f"Skipping {p}...")
            continue

        if "site-packages" not in p:
            print(f"Skipping {p}...")
            continue

        print(f"Will sort {p}...")

        if sort_start >= i:
            sort_start = i

        sort_end = i + 1

    print(f"Runfiles entry [start, end) indices: [{sort_start}, {sort_end})")

    sys_path[sort_start:sort_end] = sorted(sys_path[sort_start:sort_end], reverse=True)


print("Sys path is:")
_print_sys_path()

if os.environ.get("TEST_SORT_SYSPATH", "0") == "1":
    _sort_runfiles(sys.path)

    print("Sys path after sorting is:")
    _print_sys_path()


def expected_failure_if(should_fail):
    if should_fail:
        return unittest.expectedFailure

    def decorator(func):
        def noop(*args, **kwargs):
            func(*args, **kwargs)

        return noop

    return decorator


class ExampleTest(unittest.TestCase):
    @expected_failure_if(os.environ.get("EXPECTED_FAILURE_REGULAR_FUNC"))
    def test_regular_func(self):
        from pkg import fizz

        self.assertEquals(fizz(), "buzz")

    @expected_failure_if(os.environ.get("EXPECTED_FAILURE_LAZY_LOADED_FUNC"))
    def test_lazy_loaded_func(self):
        from pkg import foo

        self.assertEquals(foo(), "bar")

    @expected_failure_if(os.environ.get("EXPECTED_FAILURE_LAZY_LOADED_FUNC_DIRECTLY"))
    def test_lazy_loaded_func_directly(self):
        from pkg.dir.lib import foo

        self.assertEquals(foo(), "bar")

    @expected_failure_if(os.environ.get("EXPECTED_FAILURE_EXTENSION_FUNC"))
    def test_extension_func(self):
        from pkg.my_extension_1 import my_extension

        self.assertEquals(my_extension(), "my_extension_1")


if __name__ == "__main__":
    unittest.main()
