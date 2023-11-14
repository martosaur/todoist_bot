defmodule TodoistBot.Nadia.API do
  @adapter Application.compile_env!(:todoist_bot, :nadia_adapter)
  
  @callback get_updates([{atom(), any()}]) :: {:ok, [Nadia.Model.Update.t()]} | {:error, Nadia.Model.Error.t()}
  @callback delete_webhook() :: :ok | {:error, Nadia.Model.Error.t()}
  @callback set_webhook([{atom(), any()}]) :: :ok | {:error, Nadia.Model.Error.t()}
  
  defdelegate get_updates(opts), to: @adapter
  defdelegate delete_webhook(), to: @adapter
  defdelegate set_webhook(opts), to: @adapter
end