defmodule Mix.Tasks.Psa do
  use Mix.Task
  import Ecto.Query
  require Logger

  @moduledoc """
  The list of available PSAa:\n
    rich_add_enabled - announcement about switch to #project @label +assignee syntax
  """

  @psas ["rich_add_enabled"]

  @shortdoc "Sends everyone a public service announcement. Use with caution!"
  def run({_, [psa_name], _}) when psa_name in @psas do
    {:ok, _} = Application.ensure_all_started(:todoist_bot)

    r =
      TodoistBot.Interaction.User
      |> where([u], u.access_token != "")
      |> TodoistBot.Storage.Repo.all()
      |> Enum.map(fn user ->
        Task.async(fn -> notify_user(user, :"PSA_#{psa_name}") end)
      end)
      |> Task.yield_many(30000)

    IO.puts("PSA was successfully sent to #{Enum.count(r)} users!")
  end

  def run({_, a, _}) do
    IO.puts("Unknown PSA name: #{a}. Please run mix help psa to view all availables psas")
  end

  def run(args) do
    OptionParser.parse(args)
    |> run
  end

  def notify_user(%TodoistBot.Interaction.User{} = user, string_id) do
    TodoistBot.Interaction.notification(user.last_chat_id, string_id, user.language)
    |> TodoistBot.Processor.send_notification()
  end
end
