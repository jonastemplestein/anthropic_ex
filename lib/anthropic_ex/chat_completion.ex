defmodule AnthropicEx.ChatCompletion do
  @moduledoc """
  This module provides an implementation of the OpenAI chat completions API. The API reference can be found at https://platform.openai.com/docs/api-reference/chat/completions.

  ## API Fields

  The following fields can be used as parameters when creating a new chat completion:

    `:model`
    `:messages`
    `:max_tokens_to_sample`
    `:temperature`
    `:top_p`
    `:top_k`
    `:metadata`
    `:stream`

  `messages` will automatically be turned into a correctly formatted prompt before sending to the anthropic API.

  """
  @api_fields [
    :model,
    :prompt,
    :max_tokens_to_sample,
    :temperature,
    :top_p,
    :top_k,
    :metadata,
    :stream
  ]

  @doc """
  Creates a new chat completion request with the given arguments.

  ## Arguments

  - `args`: A list of key-value pairs, or a map, representing the fields of the chat completion request.

  ## Returns

  A map containing the fields of the chat completion request.

  The `:model` and `:prompt` fields are required. The `:messages` field should be a list of maps with the `OpenaiEx.ChatMessage` structure.

  Example usage:

      iex> _request = AnthropicEx.ChatCompletion.new(model: "davinci", messages: [AnthropicEx.ChatMessage.human("Hello, world!")])
      %{messages: [%{content: "Hello, world!", role: "Human"}], model: "davinci"}

      iex> _request = AnthropicEx.ChatCompletion.new(%{model: "davinci", messages: [AnthropicEx.ChatMessage.human("Hello, world!")]})
      %{messages: [%{content: "Hello, world!", role: "Human"}], model: "davinci"}
  """

  def new(args = [_ | _]) do
    args |> Enum.into(%{}) |> new()
  end

  def new(args = %{}) do
    args
    |> Map.put_new(:max_tokens_to_sample, 5000)
    |> Map.take(@api_fields)
  end

  @completion_url "/complete"

  @doc """
  Calls the chat completion 'create' endpoint.

  ## Arguments

  - `anthropic`: The OpenAI configuration.
  - `chat_completion`: The chat completion request, as a map with keys corresponding to the API fields.

  ## Returns

  A map containing the API response.

  See https://platform.openai.com/docs/api-reference/chat/completions/create for more information.
  """
  def create(anthropic = %AnthropicEx{}, chat_completion = %{stream: true}) do
    anthropic
    |> AnthropicEx.HttpSse.post(@completion_url,
      json:
        chat_completion
        |> Map.put(:prompt, generate_prompt(chat_completion.messages))
        |> add_defaults()
        |> Map.take(@api_fields)
        |> Map.put(:stream, true)
    )
    |> Stream.flat_map(& &1)
  end

  def create(anthropic = %AnthropicEx{}, chat_completion = %{}) do
    anthropic
    |> AnthropicEx.Http.post(@completion_url,
      json:
        chat_completion
        |> Map.put(:prompt, generate_prompt(chat_completion.messages))
        |> add_defaults()
        |> Map.take(@api_fields)
    )
  end

  def generate_prompt(messages) do
    prompt = messages |> Enum.map(&"\n\n#{&1.role}: #{&1.content}") |> Enum.join("")
    prompt = prompt <> "\n\nAssistant: "
    prompt
  end

  defp add_defaults(chat_completion = %{}) do
    Map.merge(
      %{
        max_tokens_to_sample: 5000
      },
      chat_completion
    )
  end
end
