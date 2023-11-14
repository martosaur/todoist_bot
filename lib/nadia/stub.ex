defmodule TodoistBot.Nadia.API.Stub do
  @behaviour TodoistBot.Nadia.API
  
  @impl true
  def get_updates(_opts), do: {:ok, []}
  
  @impl true
  def delete_webhook(), do: :ok
  
  @impl true
  def set_webhook(_opts), do: :ok
end