defmodule TodoistBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoist_bot,
      version: "2.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TodoistBot.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6"},
      {:plug, "~> 1.15"},
      {:jason, "~> 1.4"},
      {:mox, "~> 1.1", only: :test},
      {:req, "~> 0.5.6"},
      {:off_broadway_telegram, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.17"},
      {:disco_log, "1.0.0-rc.2"},
      {:mint_web_socket, "~> 1.0"}
    ]
  end
end
