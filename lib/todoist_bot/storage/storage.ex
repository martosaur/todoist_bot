defmodule TodoistBot.Storage do
  alias TodoistBot.Interaction
  require Logger

  def save_user(%Interaction{} = i) do
    case get_user(i.user.telegram_id) do
      nil ->
        i.user

      user ->
        user
    end
    |> Ecto.Changeset.change(Map.from_struct(i.user))
    |> TodoistBot.Storage.Repo.insert_or_update()
    |> case do
      {:ok, _} ->
        i

      {:error, u} ->
        Logger.error("Could not insert_or_update user: #{inspect(u)}")
        i
    end
  end

  def load_user(%Interaction{user: %{telegram_id: telegram_id}} = i) do
    case get_user(telegram_id) do
      nil ->
        Interaction.new_user_state(i)

      db_user ->
        Interaction.put_user_from_db(i, db_user)
    end
  end

  def delete_user(%Interaction{user: user} = i) do
    case TodoistBot.Storage.Repo.delete(user) do
      {:ok, _} ->
        i

      {:error, u} ->
        Logger.error("Could not delete user #{inspect(u)}")
        i
    end
  end

  def complete_authorization(auth_code, auth_state) do
    telegram_id =
      auth_state
      |> String.split(".")
      |> hd
      |> String.to_integer()

    case get_user(telegram_id) do
      nil ->
        Logger.error(
          "Received authorization for user with id: #{telegram_id}, auth_state: #{auth_state}, but couldn't find it in the db"
        )

        {:error, "Could not complete authorization"}

      user ->
        user
        |> Ecto.Changeset.change(%{auth_code: auth_code})
        |> TodoistBot.Storage.Repo.insert_or_update()
        |> case do
          {:ok, user} ->
            {:ok, user.last_chat_id, user.language}

          {:error, u} ->
            Logger.error("Could not save user #{inspect(u)}")

            {:error, "Could not complete authorization"}
        end
    end
  end

  defp get_user(telegram_id) do
    TodoistBot.Storage.Repo.get_by(Interaction.User, telegram_id: telegram_id)
  end
end
