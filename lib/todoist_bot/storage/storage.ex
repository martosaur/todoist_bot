defmodule TodoistBot.Storage do
  alias TodoistBot.Interaction
  alias TodoistBot.Repo
  alias TodoistBot.Interaction.User
  require Logger

  def save_user(%Interaction{} = i) do
    {:ok, user} = save_or_insert_user(i.user)
    %{i | user: user}
  end

  def delete_user(%Interaction{user: user} = i) do
    case Repo.delete(user) do
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
        |> User.changeset(%{auth_code: auth_code})
        |> save_or_insert_user()
        |> case do
          {:ok, user} ->
            {:ok, user.last_chat_id}

          {:error, u} ->
            Logger.error("Could not save user #{inspect(u)}")

            {:error, "Could not complete authorization"}
        end
    end
  end

  def get_user(telegram_id), do: Repo.get(User, telegram_id)

  def save_or_insert_user(user) do
    Repo.insert(user, on_conflict: :replace_all, conflict_target: :telegram_id)
  end
end
