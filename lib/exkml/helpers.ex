defmodule Exkml.Helpers do
  defmacro on_enter(name, event, state, body) do
    quote do
      def on_event({:startElement, _, unquote(name), _, _} = unquote(event), _, unquote(state)) do
        unquote(body[:do])
      end
    end
  end

  defmacro on_exit(name, event, state, body) do
    quote do
      def on_event({:endElement, _, unquote(name), _} = unquote(event), _, unquote(state)) do
        unquote(body[:do])
      end
    end
  end

  defmacro textof(path, state, body) do
    stack = path
    |> String.split("/")
    |> Enum.reverse
    |> Enum.map(&:erlang.binary_to_list/1)

    quote do
      def on_event({:characters, c}, _, %{stack: unquote(stack)} = unquote(state)) do
        var!(text) = :erlang.list_to_binary(c)
        unquote(body[:do])
      end
    end
  end


end
