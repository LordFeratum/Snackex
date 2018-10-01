defmodule SnackexTest do
  use ExUnit.Case
  doctest Snackex

  test "greets the world" do
    assert Snackex.hello() == :world
  end
end
