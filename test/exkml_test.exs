defmodule ExkmlTest do
  use ExUnit.Case
  import TestHelper
  alias Exkml.{
    Placemark,
    Point,
    Line,
    Polygon,
    Multigeometry
  }

  test "points" do
    assert "simple_points"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [%Point{x: 102.0, y: 0.5}],
        attrs: %{
          "a_bool" => "false",
          "a_float" => "2.2",
          "a_num" => "2",
          "a_string" => "first value"
        }
      },
      %Placemark{
        geoms: [%Point{x: 103.0, y: 1.5}],
        attrs: %{
          "a_bool" => "true",
          "a_float" => "2.2",
          "a_num" => "2",
          "a_string" => "second value"
        }
      }
    ]
  end

  test "lines" do
    assert "simple_lines"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [%Line{points: [%Point{x: 100.0, y: 0.0}, %Point{x: 101.0, y: 1.0}]}],
        attrs: %{"a_string" => "first value"}
      },
      %Placemark{
        geoms: [%Line{points: [%Point{x: 101.0, y: 0.0}, %Point{x: 101.0, y: 1.0}]}],
        attrs: %{"a_string" => "second value"}
      }
    ]
  end

  test "polygons" do
    assert "simple_polygons"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [
          %Polygon{
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
          }
        ],
        attrs: %{"a_string" => "first value"}
      },
      %Placemark{
        geoms: [
          %Polygon{
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
        }
      ],
      attrs: %{"a_string" => "second value"}
    }]
  end

  test "multipoints" do
    assert "simple_multipoints"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [
          %Multigeometry{geometries: [
            %Point{x: 100.0, y: 0.0},
            %Point{x: 101.0, y: 1.0}
          ]}
        ],
        attrs: %{"a_string" => "first value"}
      },
      %Placemark{
        geoms: [
          %Multigeometry{geometries: [
            %Point{x: 101.0, y: 0.0},
            %Point{x: 101.0, y: 1.0}
          ]}
        ],
        attrs: %{"a_string" => "second value"}
      }
    ]
  end

  test "multilines" do
    assert "simple_multilines"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [
          %Multigeometry{geometries: [
            %Line{points: [
              %Point{x: 100.0, y: 0.0},
              %Point{x: 101.0, y: 1.0}]},
            %Line{points: [%Point{x: 102.0, y: 2.0},
              %Point{x: 103.0, y: 3.0}]}]
          }
        ],
        attrs: %{"a_string" => "first value"}
      },
      %Placemark{
        geoms: [
          %Multigeometry{geometries: [
            %Line{points: [
              %Point{x: 101.0, y: 0.0},
              %Point{x: 102.0, y: 1.0}]},
            %Line{points: [
              %Point{x: 102.0, y: 2.0},
              %Point{x: 103.0, y: 3.0}]}]
          }
        ],
        attrs: %{"a_string" => "second value"}
      }
    ]
  end

  test "multipolygons" do
    assert "simple_multipolygons"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [%Multigeometry{geometries: [%Polygon{inner_boundaries: [],
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
        attrs: %{"a_string" => "first value"}
      },
      %Placemark{
        geoms: [%Multigeometry{geometries: [%Polygon{inner_boundaries: [],
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
        attrs: %{"a_string" => "second value"}
      }
    ]
  end

  test "data instead of SimpleData" do
    assert "untyped_simple_points"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [%Point{x: 102.0, y: 0.5}],
        attrs: %{
          "a_bool" => "false",
          "a_float" => "2.2",
          "a_num" => "2",
          "a_string" => "first value"
        }
      },
      %Placemark{
        geoms: [%Point{x: 103.0, y: 1.5}],
        attrs: %{
          "a_bool" => "true",
          "a_float" => "2.2",
          "a_num" => "2",
          "a_string" => "second value"
        }
      }
    ]
  end

  test "points and lines" do
    assert "points_and_lines_multigeom_sans_schema"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([]) == [
      %Placemark{
        geoms: [%Multigeometry{
          geometries: [
            %Point{x: 102.0, y: 0.5},
            %Line{points: [
              %Point{x: 101.0, y: 0.0},
              %Point{x: 101.0, y: 1.0}
            ]}
          ]
        }],
        attrs: %{"a_string" => "first value"}
      }
    ]
  end

  test "3 dimension" do
    assert "line_extra_dimension"
    |> kml_fixture
    |> Exkml.stream!()
    |> Enum.into([])
    |> Enum.each(fn %Placemark{geoms: [%Line{points: points}]} ->
      Enum.each(points, fn %Point{z: z} -> assert z != nil end)
    end)
  end

  # test "malformed" do
  #   Process.flag(:trap_exit, true)

  #   assert "malformed_kml"
  #   |> kml_fixture
  #   |> Exkml.placemarks!()
  #   |> Enum.into([])

  #   assert_receive {:EXIT, _, {:fatal, _}}
  #   Process.flag(:trap_exit, false)
  # end


  Enum.each([
    # {"boundaries", [Multipoint]},
    {"cgis-en-6393", [Point]},
    {"la_bikelanes", [Multiline, Line]},
    {"noaa", [Point]},
    # {"terrassa", [Multipolygon, Point]},
    # {"usbr", [Multipolygon]},
    # {"wards", [Multipolygon, Polygon]}
  ], fn {name, kinds} ->
    test "smoke #{name}" do
      expected_set = MapSet.new(unquote(kinds))

      assert "smoke/#{unquote(name)}"
      |> kml_fixture
      |> Exkml.stream!()
      |> Enum.each(fn %Placemark{geoms: shapes} ->
        Enum.each(shapes, fn actual ->
          assert actual.__struct__ in expected_set
        end)
      end)
    end
  end)

  # test "large" do
  #   File.stream!("/home/chris/Downloads/large.kml", [], 2048)
  #   |> Exkml.placemarks!
  #   |> Enum.take(20_000)

  #   receive do
  #     any -> IO.inspect {:wat, any}
  #   after
  #     1000 -> IO.inspect :nope
  #   end
  # end

end
