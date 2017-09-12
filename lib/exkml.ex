defmodule Exkml do
  import SweetXml
  @moduledoc """
  Documentation for Exkml.
  """

  defmodule Point do
    defstruct [:x, :y, :z]
  end

  defmodule Line do
    defstruct [:points]
  end

  defmodule Polygon do
    defstruct [:outer_boundary, inner_boundaries: []]
  end

  defmodule Multipoint do
    defstruct points: []
  end

  defmodule Multiline do
    defstruct lines: []
  end

  defmodule Multipolygon do
    defstruct polygons: []
  end

  defp do_str_to_point([x, y]) do
    with {x, _} <- Float.parse(x),
      {y, _} <- Float.parse(y) do
      {:ok, %Point{x: x, y: y}}
    else
      _ -> :error
    end
  end

  defp do_str_to_point([x, y, z]) do
    with {x, _} <- Float.parse(x),
      {y, _} <- Float.parse(y),
      {z, _} <- Float.parse(z) do
      {:ok, %Point{x: x, y: y, z: z}}
    else
      _ -> :error
    end
  end

  defp str_to_point(point_str) do
    point_str
    |> String.split(",")
    |> do_str_to_point
    |> case do
      :error -> {:error, "Invalid point #{point_str}"}
      {:ok, _} = ok -> ok
    end
  end

  defp str_to_line(line_str) do
    line_str
    |> String.trim
    |> String.split(" ")
    |> extract_many(&str_to_point/1)
    |> case do
      {:ok, points} -> {:ok, %Line{points: points}}
      err -> err
    end
  end

  def extract_many(things, fun) do
    things
    |> Enum.reduce_while([], fn thing, acc ->
      case fun.(thing) do
        {:ok, shape_like} -> {:cont, [shape_like | acc]}
        {:error, _} = e -> {:halt, e}
      end
    end)
    |> case do
      {:error, _} = e -> e
      shapes -> {:ok, Enum.reverse(shapes)}
    end
  end

  defp add_geom(geoms, pm, fun) do
    case fun.(pm) do
      :none -> geoms
      {:ok, geom} -> [geom | geoms]
      {:error, _} = e -> e
    end
  end

  defp shape(nil, _, _), do: :none
  defp shape(pm, xp, to_shape) do
    case xpath(pm, xp) do
      "" -> :none
      [] -> :none
      shape_str -> to_shape.(shape_str)
    end
  end

  defp extract_point(pm), do: shape(pm, ~x"//Point/coordinates/text()"s, &str_to_point/1)
  defp extract_line(pm), do: shape(pm, ~x"//LineString/coordinates/text()"s, &str_to_line/1)

  defp extract_linear_ring(pm), do: shape(pm, ~x"//LinearRing/coordinates/text()"s, &str_to_line/1)

  defp extract_polygon(pm) do
    with {:ok, outer_boundary} <- shape(pm, ~x"//Polygon/outerBoundaryIs/LinearRing/coordinates/text()"s, &str_to_line/1),
      {:ok, inner_boundaries} <- extract_many(xpath(pm, ~x"//Polygon/innerBoundaryIs"el), &extract_linear_ring/1) do
      {:ok, %Polygon{
        outer_boundary: outer_boundary,
        inner_boundaries: inner_boundaries
      }}
    end
  end

  defp point_from_placemark(pm), do: pm |> xpath(~x"//Placemark/Point"e) |> extract_point
  defp line_from_placemark(pm), do: pm |> xpath(~x"//Placemark/LineString"e) |> extract_line
  defp polygon_from_placemark(pm), do: pm |> xpath(~x"//Placemark/Polygon"e) |> extract_polygon

  defp multipoint_from_placemark(pm) do
    case xpath(pm, ~x"//Placemark/MultiGeometry/Point"l) do
      [] -> :none
      coords ->
        with {:ok, points} <- extract_many(coords, &extract_point/1) do
          {:ok, %Multipoint{points: points}}
        end
    end
  end

  defp multiline_from_placemark(pm) do
    case xpath(pm, ~x"//Placemark/MultiGeometry/LineString"l) do
      [] -> :none
      coords ->
        with {:ok, lines} <- extract_many(coords, &extract_line/1) do
          {:ok, %Multiline{lines: lines}}
        end
    end
  end

  defp multipolygon_from_placemark(pm) do
    case xpath(pm, ~x"//Placemark/MultiGeometry/Polygon"l) do
      [] -> :none
      coords ->
        with {:ok, polygons} <- extract_many(coords, &extract_polygon/1) do
          {:ok, %Multipolygon{polygons: polygons}}
        end
    end
  end

  defp extract_geoms(pm) do
    []
    |> add_geom(pm, &point_from_placemark/1)
    |> add_geom(pm, &line_from_placemark/1)
    |> add_geom(pm, &polygon_from_placemark/1)
    |> add_geom(pm, &multipoint_from_placemark/1)
    |> add_geom(pm, &multiline_from_placemark/1)
    |> add_geom(pm, &multipolygon_from_placemark/1)
  end

  defp simple_data_to_attrs(pm) do
    pm
    |> xpath(~x"//SimpleData"el)
    |> Enum.map(fn attr ->
      value = attr
      |> xpath(~x"text()"s)
      |> String.trim
      {xpath(attr, ~x"@name"s), value}
    end)
  end

  defp data_to_attrs(pm) do
    pm
    |> xpath(~x"//Data"el)
    |> Enum.map(fn attr ->
      value = attr
      |> xpath(~x"//value/text()"s)
      |> String.trim

      {xpath(attr, ~x"@name"s), value}
    end)
  end

  def maybe_put(map, _, nil), do: map
  def maybe_put(map, name, value), do: Map.put(map, name, value)


  defp to_placemark({_, pm}) do
    with geoms when is_list(geoms) <- extract_geoms(pm) do
      attrs = (simple_data_to_attrs(pm) ++ data_to_attrs(pm))
      |> Enum.into(%{})
      |> maybe_put("name", xpath(pm, ~x"//Placemark/name/text()"))
      |> maybe_put("description", xpath(pm, ~x"//Placemark/description/text()"))
      |> maybe_put("snippet", xpath(pm, ~x"//Placemark/snippet/text()"))

      {geoms, attrs}
    end
  end


  @doc """
    Parse a stream of binaries, return a stream of placemarks
  """
  def placemarks!(doc) do
    SweetXml.stream_tags(doc, [:Placemark, :placemark])
    |> Stream.map(&to_placemark/1)
  end
end
