"""Tests for PROJ_NAME_SNAKE."""

from PROJ_NAME_SNAKE import __version__, main


def test_version() -> None:
    """Test that version is defined."""
    assert __version__ == "0.1.0"


def test_main(capsys) -> None:
    """Test main function output."""
    main()
    captured = capsys.readouterr()
    assert "Hello from PROJ_NAME_SNAKE" in captured.out
