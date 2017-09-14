defmodule TestHelper do
  def kml_fixture(name) do
    Path.join([__DIR__, "fixtures", "#{name}.kml"])
    |> File.stream!([], 64)
  end
end

ExUnit.start()
