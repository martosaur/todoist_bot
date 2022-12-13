defmodule TodoistBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoist_bot,
      version: "1.0.2",
      elixir: "~> 1.9",
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
      {:httpoison, "~> 1.6.1", override: true},
      {:nadia, git: "https://github.com/zhyu/nadia.git"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.8"},
      {:jason, "~> 1.1"}
    ]
  end
end
