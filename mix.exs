defmodule TodoistBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoist_bot,
      version: "1.0.4",
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
      {:httpoison, "~> 2.2.0", override: true},
      {:nadia, git: "https://github.com/zhyu/nadia.git"},
      {:plug_cowboy, "~> 2.6"},
      {:plug, "~> 1.15"},
      {:jason, "~> 1.4"}
    ]
  end
end
