defmodule TestHelper do
  def kml_fixture(name) do
    Path.join([__DIR__, "fixtures", "#{name}.kml"])
    |> File.stream!([], 2048)
  end
end

ExUnit.start()
