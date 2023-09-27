defmodule AnthropicEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: AnthropicEx.Finch},
      {DynamicSupervisor, strategy: :one_for_one, name: AnthropicEx.FinchSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
