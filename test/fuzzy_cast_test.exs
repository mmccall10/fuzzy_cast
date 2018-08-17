defmodule FuzzyCastTest do
  use ExUnit.Case
  doctest FuzzyCast

  test "greets the world" do
    assert FuzzyCast.hello() == :world
  end
end
