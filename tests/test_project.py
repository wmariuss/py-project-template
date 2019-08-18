import pytest


@pytest.mark.xfail
def test_fails():
    assert False, "Time to write some tests!"
