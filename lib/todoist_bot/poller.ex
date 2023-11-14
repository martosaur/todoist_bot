defmodule TodoistBot.Poller do
  use GenServer
  require Logger
  
  alias TodoistBot.Nadia.API

  def start_link(_state) do
    Logger.info("Started poller")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    update()
    {:ok, 0}
  end

  def handle_cast(:update, offset) do
    new_offset =
      API.get_updates(offset: offset)
      |> process_messages

    {:noreply, new_offset + 1, 100}
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  # Client

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  # Helpers

  defp process_messages({:ok, []}), do: -1

  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{update_id: id} = message ->
      Task.start(TodoistBot.Processor, :process_message, [message])
      id
    end)
    |> List.last()
  end

  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}) do
    Logger.error("Error polling updates: #{inspect(reason)}")

    -1
  end
end
