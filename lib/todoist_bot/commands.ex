defmodule TodoistBot.Commands do
  require Logger

  alias TodoistBot.Interaction
  alias TodoistBot.User
  alias TodoistBot.Repo
  alias TodoistBot.Todoist

  def match(interaction) do
    case interaction do
      %{request: %{callback: "/logout.confirm.yes"}} ->
        Repo.delete!(interaction.user)

        interaction
        |> Interaction.put_resp_text("Who are you? Do I know you?")
        |> Interaction.put_resp_type(:edit_text)

      %{request: %{text: "/help"}} ->
        interaction
        |> Interaction.put_resp_text("""
        /help - show this help
        /about - about this bot
        /logout - make this bot forget you
        """)
        |> Interaction.put_resp_parse_mode_markdown()
        |> Interaction.put_resp_type(:message)

      %{request: %{text: "/about"}} ->
        interaction
        |> Interaction.put_resp_text(
          "*Telegram for Todoist* is a simple bot for adding Inbox tasks through Telegram. This bot is created by @martosaur and is not created by, affiliated with, or supported by Doist. If you want to contribute please see [this repo](https://github.com/martosaur/todoist_bot)"
        )
        |> Interaction.put_resp_parse_mode_markdown()
        |> Interaction.put_resp_type(:message)

      %{request: %{text: "/logout"}} ->
        interaction
        |> Interaction.put_resp_text(
          "Are you sure you want to logout and disappear without a trace from this bot's life?"
        )
        |> Interaction.add_resp_inline_keyboard()
        |> Interaction.add_resp_inline_keyboard_row()
        |> Interaction.add_resp_inline_keyboard_callback_button(
          "Yes",
          "/logout.confirm.yes"
        )
        |> Interaction.put_resp_type(:message)

      %{user: %{access_token: token} = user, request: %{text: text}}
      when not is_nil(token) and not is_nil(text) ->
        "rest/v2/tasks"
        |> Todoist.API.request(token, method: :post, json: %{content: text})
        |> case do
          {:ok, %{status: 200}} ->
            interaction
            |> Interaction.put_resp_text("Task added")
            |> Interaction.put_resp_type(:message)

          {:ok, %{status: code}} when code in [401, 403] ->
            with {:ok, user} <-
                   user |> User.changeset(%{auth_code: nil, access_token: nil}) |> Repo.update() do
              %{interaction | user: user}
              |> request_authorization()
              |> Interaction.put_resp_text(
                "Todoist did not believe me and shut the door 😱 I'll have to authenticate you again."
              )
              |> Interaction.put_resp_type(:message)
            else
              _error ->
                interaction
                |> Interaction.put_resp_text(
                  "Something went terribly wrong 😢 Let's maybe try again?"
                )
                |> Interaction.put_resp_type(:message)
            end

          {_, error} ->
            Logger.error("Could not add task", interaction: interaction, error: error)

            interaction
            |> Interaction.put_resp_text("Something went terribly wrong 😢 Let's maybe try again?")
            |> Interaction.put_resp_type(:message)
        end

      %{user: %{auth_code: nil}} ->
        interaction
        |> request_authorization()
        |> Interaction.put_resp_type(:message)

      _ ->
        interaction
        |> Interaction.put_resp_text("Did you say something?")
        |> Interaction.put_resp_type(:message)
    end
  end

  defp request_authorization(%Interaction{} = i) do
    i
    |> Interaction.put_resp_text("Please authorize this bot to access your account")
    |> Interaction.add_resp_inline_keyboard()
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_link_button(
      "Authorize on Todoist",
      "#{Application.fetch_env!(:todoist_bot, :app_host)}authorize?uuid=#{i.user.auth_state}"
    )
    |> Interaction.add_resp_inline_keyboard_row()
  end
end
