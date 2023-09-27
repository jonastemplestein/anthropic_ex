defmodule AnthropicEx.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "Community maintained anthropic API client based on openai_ex"
  @source_url "https://github.com/jonastemplestein/anthropic_ex"

  def project do
    [
      app: :anthropic_ex,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
      # docs: docs(),
      # preferred_cli_env: [
      #   docs: :docs,
      #   "hex.publish": :docs
      # ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AnthropicEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.16"},
      {:jason, "~> 1.4"}
      # {:multipart, "~> 0.4"},
      # {:ex_doc, ">= 0.0.0", only: :docs},
      # {:credo, "~> 1.6", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: @description,
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
