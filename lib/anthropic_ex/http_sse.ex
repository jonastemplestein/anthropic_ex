defmodule AnthropicEx.HttpSse do
  @moduledoc false
  require Logger

  # This API has an absolutely horrible response format

  @doc false
  def post(openai = %AnthropicEx{}, url, json: json) do
    request = AnthropicEx.Http.build_post(openai, url, json: json)

    me = self()
    ref = make_ref()

    task =
      Task.async(fn ->
        on_chunk = fn chunk, _acc -> send(me, {:chunk, chunk, ref}) end
        request |> Finch.stream(AnthropicEx.Finch, nil, on_chunk)
        send(me, {:done, ref})
      end)

    _status = receive(do: ({:chunk, {:status, status}, ^ref} -> status))
    _headers = receive(do: ({:chunk, {:headers, headers}, ^ref} -> headers))

    Stream.resource(fn -> {"", ref, task} end, &next_sse/1, fn {_data, _ref, task} ->
      Task.shutdown(task)
    end)
  end

  @doc false
  defp next_sse({acc, ref, task}) do
    receive do
      {:chunk, {:data, evt_data}, ^ref} ->
        {tokens, next_acc} = tokenize_data(evt_data, acc)
        {[tokens], {next_acc, ref, task}}

      {:done, ^ref} ->
        if acc != "" do
          Logger.warning(inspect(Jason.decode!(acc)))
        end

        {:halt, {acc, ref, task}}
    end
  end

  @doc false
  defp tokenize_data(evt_data, acc) do
    # a single event will always contain one or more such blocks of two rows
    #
    # event: completion
    # data: {"completion": " Hello", "stop_reason": null, "model": "claude-2.0"}
    #
    # event: completion
    # data: {"completion": "!", "stop_reason": null, "model": "claude-2.0"}
    #
    # event: ping
    # data: {}
    #
    # ultra janky parser - needs to handle errors as per here: https://docs.anthropic.com/claude/reference/streaming
    IO.puts("---")
    IO.puts(evt_data)

    {String.split(evt_data, "\r\n\r\n")
     |> Enum.filter(&String.starts_with?(&1, "event: completion"))
     |> Enum.map(fn str ->
       str |> String.split("data: ") |> tl() |> Jason.decode!() |> Map.get("completion")
     end)
     |> dbg(), acc}
  end
end
