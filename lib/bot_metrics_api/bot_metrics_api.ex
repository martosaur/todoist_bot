defmodule TodoistBot.BotMetricsApi do
  use HTTPoison.Base

  def process_url(url) do
    "https://api.bot-metrics.com/" <> url
  end

  def process_request_options(options) do
    Keyword.put(options, :params, %{"token" => TodoistBot.Config.bot_metrics_token()})
  end

  def process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers]
  end

  def process_request_body(body) do
    Poison.encode!(body)
  end

  def send_incoming_request_to_analytics(%TodoistBot.Interaction{} = i) do
    if TodoistBot.Interaction.callback_query?(i) do
      i.request.callback_query
    else
      i.request.text
    end
    |> post_message(:incoming, i.user.telegram_id)
  end

  def send_outgoing_request_to_analytics(%TodoistBot.Interaction{} = i) do
    case i.response.type do
      t when t in [:message, :edit_text] ->
        i.response.text

      t when t == :edit_markup ->
        "editing_markup"

      t when t == :answer_callback ->
        "callback: #{i.response.answer_callback_query_text}"
    end
    |> post_message(:outgoing, i.user.telegram_id)
  end

  def post_message(text, message_type, user_id) do
    body = %{
      text: text,
      message_type: message_type,
      user_id: user_id,
      platform: "telegram"
    }

    post("v1/messages", body)
  end
end
