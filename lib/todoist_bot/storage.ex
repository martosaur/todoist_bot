defmodule TodoistBot.Storage do
  alias TodoistBot.Interaction
  require Logger

  def save_user(%Interaction{} = i) do
    save_user(
      i.user.id,
      i.user.last_chat_id,
      i.user.auth_code,
      i.user.auth_state,
      i.user.access_token,
      i.user.language
    )

    i
  end

  def load_user(%Interaction{user: %{id: user_id}} = i) do
    case get_user(user_id) do
      [{^user_id, _last_chat_id, auth_code, auth_state, access_token, language}] ->
        Interaction.put_user_state(
          i,
          auth_code: auth_code,
          auth_state: auth_state,
          access_token: access_token,
          language: language
        )

      [] ->
        Interaction.new_user_state(i)
    end
  end

  def complete_authorization(auth_code, auth_state) do
    user_id =
      auth_state
      |> String.split(".")
      |> hd
      |> String.to_integer()

    case get_user(user_id) do
      [{^user_id, last_chat_id, _auth_code, ^auth_state, access_token, language}] ->
        save_user(user_id, last_chat_id, auth_code, auth_state, access_token, language)
        {:ok, last_chat_id, language}

      r ->
        Logger.error(
          "Received authorization for user with id: #{user_id}, auth_state: #{auth_state}, but found in db only: #{
            inspect(r)
          }"
        )

        {:error, "Could not complete authorization"}
    end
  end

  defp get_user(user_id) do
    :ets.lookup(:users, user_id)
  end

  defp save_user(user_id, last_chat_id, auth_code, auth_state, access_token, language) do
    :ets.insert(:users, {user_id, last_chat_id, auth_code, auth_state, access_token, language})
  end
end
