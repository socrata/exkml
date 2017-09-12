# Exkml

parse KML placemarks from a stream

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exkml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exkml, "~> 0.1.0"}
  ]
end
```

## Usage
```elixir
File.stream!("something.kml", [], 2048)
|> Exkml.placemarks!()
|> Enum.into([])
|> IO.inspect
```
might print
```elixir
[{[
  %Multiline{lines: [
    %Line{points: [
      %Point{x: 101.0, y: 0.0},
      %Point{x: 101.0, y: 1.0}]}]},
  %Multipoint{points: [
    %Point{x: 102.0, y: 0.5}]}],
  %{"a_string" => "first value"}}
]
```
