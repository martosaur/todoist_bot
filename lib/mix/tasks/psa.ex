defmodule Mix.Tasks.Psa do
  use Mix.Task
  require Logger
  require TodoistBot.Storage
  alias TodoistBot.Storage

  @moduledoc """
  The list of available PSAa:\n
    rich_add_enabled - announcement about switch to #project @label +assignee syntax
  """

  @psas ["rich_add_enabled"]
  # :ets.fun2ms(fn {_, %{access_token: token}} = res when token != "" -> res end)
  @active_users [{{:_, %{access_token: :"$1"}}, [{:"/=", :"$1", ""}], [:"$_"]}]

  @shortdoc "Sends everyone a public service announcement. Use with caution!"
  def run({_, [psa_name], _}) when psa_name in @psas do
    {:ok, _} = Application.ensure_all_started(:todoist_bot)

    r =
      Storage.with_dets Storage.storage() do
        :dets.select(Storage.storage(), @active_users)
      end
      |> Enum.map(fn {_, user} ->
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
