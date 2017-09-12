defmodule ExkmlTest do
  use ExUnit.Case
  import TestHelper
  alias Exkml.{
    Point,
    Line,
    Polygon,
    Multipoint,
    Multiline,
    Multipolygon
  }

  test "points" do
    assert "simple_points"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [{
      [%Point{x: 102.0, y: 0.5}],
      %{"a_bool" => "false", "a_float" => "2.2", "a_num" => "2",
      "a_string" => "first value"}},
      {[%Point{x: 103.0, y: 1.5}],
      %{"a_bool" => "true", "a_float" => "2.2", "a_num" => "2",
      "a_string" => "second value"}}
    ]
  end

  test "lines" do
    assert "simple_lines"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [
      {[%Line{points: [%Point{x: 100.0, y: 0.0}, %Point{x: 101.0, y: 1.0}]}],
        %{"a_string" => "first value"}},
      {[%Line{points: [%Point{x: 101.0, y: 0.0}, %Point{x: 101.0, y: 1.0}]}],
        %{"a_string" => "second value"}}
    ]
  end

  test "polygons" do
    assert "simple_polygons"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [
      {[%Polygon{
        inner_boundaries: [
          %Line{points: [
            %Point{x: 100.2, y: 0.2},
            %Point{x: 100.8, y: 0.2},
            %Point{x: 100.8, y: 0.8},
            %Point{x: 100.2, y: 0.8},
            %Point{x: 100.2, y: 0.2}]
          }
        ],
        outer_boundary: %Line{points: [
          %Point{x: 100.0, y: 0.0},
          %Point{x: 101.0, y: 0.0},
          %Point{x: 101.0, y: 1.0},
          %Point{x: 100.0, y: 1.0},
          %Point{x: 100.0, y: 0.0}]
        }
      }], %{"a_string" => "first value"}},
      {[%Polygon{
        inner_boundaries: [
          %Line{points: [
            %Point{x: 100.2, y: 0.2},
            %Point{x: 100.8, y: 0.2},
            %Point{x: 100.8, y: 0.8},
            %Point{x: 100.2, y: 0.8},
            %Point{x: 100.2, y: 0.2}]
          }
        ],
        outer_boundary: %Line{
          points: [
            %Point{x: 100.0, y: 0.0},
            %Point{x: 101.0, y: 0.0},
            %Point{x: 101.0, y: 1.0},
            %Point{x: 100.0, y: 1.0},
            %Point{x: 100.0, y: 0.0}
          ]
        }
      }], %{"a_string" => "second value"}}
    ]
  end

  test "multipoints" do
    assert "simple_multipoints"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [
      {[%Multipoint{points: [
        %Point{x: 100.0, y: 0.0},
        %Point{x: 101.0, y: 1.0}]
      }],  %{"a_string" => "first value"}},
      {[%Multipoint{points: [
        %Point{x: 101.0, y: 0.0},
        %Point{x: 101.0, y: 1.0}]
      }], %{"a_string" => "second value"}}
    ]
  end

  test "multilines" do
    assert "simple_multilines"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [
      {[%Multiline{lines: [
        %Line{points: [
          %Point{x: 100.0, y: 0.0},
          %Point{x: 101.0, y: 1.0}]},
        %Line{points: [%Point{x: 102.0, y: 2.0},
          %Point{x: 103.0, y: 3.0}]}]}], %{"a_string" => "first value"}},
      {[%Multiline{lines: [
        %Line{points: [
          %Point{x: 101.0, y: 0.0},
          %Point{x: 102.0, y: 1.0}]},
        %Line{points: [
          %Point{x: 102.0, y: 2.0},
          %Point{x: 103.0, y: 3.0}]}]}], %{"a_string" => "second value"}}]
  end

  test "multipolygons" do
    assert "simple_multipolygons"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [{[%Multipolygon{polygons: [%Polygon{inner_boundaries: [],
          outer_boundary: %Line{points: [%Point{x: 102.0, y: 2.0},
           %Point{x: 103.0, y: 2.0}, %Point{x: 103.0, y: 3.0},
           %Point{x: 102.0, y: 3.0}, %Point{x: 102.0, y: 2.0}]}},
          %Polygon{inner_boundaries: [%Line{points: [%Point{x: 100.2,
             y: 0.2}, %Point{x: 100.8, y: 0.2},
            %Point{x: 100.8, y: 0.8}, %Point{x: 100.2, y: 0.8},
            %Point{x: 100.2, y: 0.2}]}],
          outer_boundary: %Line{points: [%Point{x: 100.0, y: 0.0},
           %Point{x: 101.0, y: 0.0}, %Point{x: 101.0, y: 1.0},
           %Point{x: 100.0, y: 1.0}, %Point{x: 100.0, y: 0.0}]}}]}],
      %{"a_string" => "first value"}},
      {[%Multipolygon{polygons: [%Polygon{inner_boundaries: [],
            outer_boundary: %Line{points: [%Point{x: 103.0, y: 2.0},
             %Point{x: 102.0, y: 2.0}, %Point{x: 103.0, y: 3.0},
             %Point{x: 102.0, y: 3.0}, %Point{x: 103.0, y: 2.0}]}},
            %Polygon{inner_boundaries: [%Line{points: [%Point{x: 100.2,
               y: 0.2}, %Point{x: 100.8, y: 0.2},
              %Point{x: 100.8, y: 0.8}, %Point{x: 100.2, y: 0.8},
              %Point{x: 100.2, y: 0.2}]}],
            outer_boundary: %Line{points: [%Point{x: 100.0, y: 0.0},
             %Point{x: 101.0, y: 0.0}, %Point{x: 101.0, y: 1.0},
             %Point{x: 100.0, y: 1.0}, %Point{x: 100.0, y: 0.0}]}}]}],
      %{"a_string" => "second value"}}
    ]
  end

  test "data instead of SimpleData" do
    assert "untyped_simple_points"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [{[%Point{x: 102.0, y: 0.5}],
      %{"a_bool" => "false", "a_float" => "2.2", "a_num" => "2",
      "a_string" => "first value"}},
      {[%Point{x: 103.0, y: 1.5}],
      %{"a_bool" => "true", "a_float" => "2.2", "a_num" => "2",
      "a_string" => "second value"}}
    ]
  end

  test "points and lines" do
    assert "points_and_lines_multigeom_sans_schema"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [{[
      %Multiline{lines: [
        %Line{points: [
          %Point{x: 101.0, y: 0.0},
          %Point{x: 101.0, y: 1.0}]}]},
      %Multipoint{points: [
        %Point{x: 102.0, y: 0.5}]}],
      %{"a_string" => "first value"}}
    ]

    assert "points_and_lines_multigeom"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([]) == [{[
      %Multiline{lines: [
        %Line{points: [
          %Point{x: 101.0, y: 0.0},
          %Point{x: 101.0, y: 1.0}]}]},
      %Multipoint{points: [
        %Point{x: 102.0, y: 0.5}]}],
      %{"a_string" => "first value"}}
    ]
  end

  test "3 dimension" do
    assert "line_extra_dimension"
    |> kml_fixture
    |> Exkml.placemarks!()
    |> Enum.into([])
    |> Enum.each(fn {[%Line{points: points}], _attrs} ->
      Enum.each(points, fn %Point{z: z} -> assert z != nil end)
    end)
  end

end
