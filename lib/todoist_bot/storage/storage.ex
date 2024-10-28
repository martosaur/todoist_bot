defmodule TodoistBot.Storage do
  alias TodoistBot.Interaction
  require Logger

  def storage do
    Application.fetch_env!(:todoist_bot, :dets_file) |> String.to_atom()
  end

  defmacro with_dets(filename, do: block) do
    quote do
      {:ok, _} = :dets.open_file(unquote(filename), type: :set)
      result = unquote(block)
      :dets.close(unquote(filename))
      result
    end
  end

  def save_user(%Interaction{} = i) do
    {:ok, user} = save_or_insert_user(i.user)
    %{i | user: user}
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
    with_dets storage() do
      case :dets.delete(storage(), user.telegram_id) do
        :ok ->
          i

        {:error, u} ->
          Logger.error("Could not delete user #{inspect(u)}")
          i
      end
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
        |> Map.put(:auth_code, auth_code)
        |> save_or_insert_user()
        |> case do
          {:ok, user} ->
            {:ok, user.last_chat_id, user.language}

          {:error, u} ->
            Logger.error("Could not save user #{inspect(u)}")

            {:error, "Could not complete authorization"}
        end
    end
  end

  def get_user(telegram_id) do
    with_dets storage() do
      case :dets.lookup(storage(), telegram_id) do
        [{^telegram_id, user}] -> user
        _ -> nil
      end
    end
  end

  def save_or_insert_user(%{telegram_id: telegram_id} = user) do
    with_dets storage() do
      user_for_insertion =
        case get_user(telegram_id) do
          nil ->
            user

          existing_user ->
            Map.merge(existing_user, user)
        end

      case :dets.insert(storage(), {telegram_id, user_for_insertion}) do
        :ok ->
          {:ok, user_for_insertion}

        error ->
          error
      end
    end
  end
end
