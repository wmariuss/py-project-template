import pytest


@pytest.mark.xfail
def test_fails() -> None:
    assert False, "Time to write some tests!"
