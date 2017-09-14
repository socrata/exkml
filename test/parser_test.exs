defmodule ParserTest do
  use ExUnit.Case
  import TestHelper

  test "points" do
    assert "simple_points"
    |> kml_fixture
    |> Exkml.stream
    |> Enum.into([])
    |> IO.inspect
  end

end
