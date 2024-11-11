defmodule TodoistBot.Telegram.API do
  @adapter Application.compile_env!(:todoist_bot, :telegram_adapter)

  @callback request(request :: Req.Request.t()) ::
              {:ok, Req.Response.t()} | {:error, Exception.t()}

  def new(method) do
    token = Application.fetch_env!(:todoist_bot, :bot_token)

    Req.new(
      base_url: "https://api.telegram.org",
      url: "bot{token}/#{method}",
      path_params: [token: token],
      path_params_style: :curly,
      method: :post
    )
  end

  def request(endpoint, body) do
    endpoint
    |> new()
    |> Req.merge(json: body)
    |> @adapter.request()
  end
end
