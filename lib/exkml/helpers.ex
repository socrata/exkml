defmodule Exkml.Helpers do
  defmacro on_enter(name, event, state, body) do
    quote do
      def handle_event(:start_element, {unquote(name), _attrs} = unquote(event), unquote(state)) do
        {:ok, unquote(body[:do])}
      end
    end
  end

  defmacro on_exit(name, state, body) do
    quote do
      def handle_event(:end_element, unquote(name), unquote(state)) do
        {:ok, unquote(body[:do])}
      end
    end
  end

  defmacro textof(path, state, body) do
    stack = path
    |> String.split("/")
    |> Enum.reverse

    quote do
      def handle_event(:characters, c, %{stack: unquote(stack)} = unquote(state)) do
        var!(text) = c
        {:ok, unquote(body[:do])}
      end
    end
  end

  def get_attr_name(attribute_name, path) do
    case {attribute_name, path} do
      {:unknown, [{_, [{"name", attr_name}]} | _]} -> attr_name
      {:unknown, [_, {_, [{"name", attr_name}]} | _]} -> attr_name
      {attr_name, _} when attr_name != :unknown -> attr_name
    end
  end

  defmacro handle_empty_textof(path, attribute_name, state, body) do
    stack = path
    |> String.split("/")
    |> Enum.reverse

    quote do
      def handle_event(:characters, c, %{stack: unquote(stack)} = unquote(state)) do
        var!(text) = c
        {:ok, unquote(body[:do])}
      end

      def handle_event(:end_element, name, %{placemark: %Exkml.Placemark{attrs: attrs}, stack: [name | stack_tail] = unquote(stack), path: path} = state) do
        attr_name = Exkml.Helpers.get_attr_name(unquote(attribute_name), path)

        if !Map.has_key?(attrs, attr_name) do
          {:ok, %Exkml.State{Exkml.put_attribute(state, attr_name, nil) | stack: stack_tail, path: tl(path)}}
        else
          {:ok, %Exkml.State{state | stack: stack_tail, path: tl(path)}}
        end
      end
    end
  end
end
