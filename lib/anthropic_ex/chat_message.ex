defmodule AnthropicEx.ChatMessage do
  @moduledoc """
  Used to produce an Anthropic prompt later

  ## API Fields

  The following fields can be used as parameters when creating a new chat message:

  - `:content`
  - `:role`
  """

  defp new(role, content) do
    %{
      role: role,
      content: content
    }
  end

  @doc """
  Create a `ChatMessage` map with role `human`.

  Example usage:

      iex> _message = AnthropicEx.ChatMessage.human("Hello, world!")
      %{content: "Hello, world!", role: "Human"}
  """
  def human(content), do: new("Human", content)

  @doc """
  Create a `ChatMessage` map with role `assistant`.

  Example usage:

      iex> _message = AnthropicEx.ChatMessage.assistant("Hello, world!")
      %{content: "Hello, world!", role: "Assistant"}
  """
  def assistant(content), do: new("Assistant", content)
end
