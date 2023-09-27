defmodule AnthropicEx.Http do
  @moduledoc false

  @base_url "https://api.anthropic.com/v1"

  @doc false
  def headers(anthropic = %AnthropicEx{}) do
    [
      {"x-api-key", anthropic.api_key},
      {"anthropic-version", "2023-06-01"},
      {"accept", "application/json"}
    ]
  end

  @doc false
  def post(anthropic = %AnthropicEx{}, url, json: json) do
    build_post(anthropic, url, json: json)
    |> finch_run()
  end

  @doc false
  def build_post(anthropic = %AnthropicEx{}, url, json: json) do
    :post
    |> Finch.build(
      @base_url <> url,
      headers(anthropic) ++ [{"Content-Type", "application/json"}],
      Jason.encode_to_iodata!(json)
    )
  end

  @doc false
  def get(anthropic = %AnthropicEx{}, url) do
    :get
    |> Finch.build(@base_url <> url, headers(anthropic))
    |> finch_run()
  end

  @doc false
  def delete(anthropic = %AnthropicEx{}, url) do
    :delete
    |> Finch.build(@base_url <> url, headers(anthropic))
    |> finch_run()
  end

  @doc false
  def finch_run(finch_request) do
    finch_request
    |> Finch.request!(AnthropicEx.Finch, receive_timeout: 45_000)
    |> dbg()
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
