defmodule TodoistBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoist_bot,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TodoistBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.4.3"},
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.5"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:distillery, "~> 2.0"}
    ]
  end
end
