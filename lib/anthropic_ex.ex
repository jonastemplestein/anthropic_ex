defmodule AnthropicEx do
  @enforce_keys [:api_key]
  defstruct api_key: nil

  def new(api_key) do
    %AnthropicEx{
      api_key: api_key
    }
  end
end
