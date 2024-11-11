defmodule TodoistBot.Todoist.API do
  @adapter Application.compile_env!(:todoist_bot, :todoist_adapter)

  @callback request(request :: Req.Request.t()) ::
              {:ok, Req.Response.t()} | {:error, Exception.t()}

  def get_access_token(auth_code) do
    body = %{
      client_id: Application.fetch_env!(:todoist_bot, :todoist_app_client_id),
      client_secret: Application.fetch_env!(:todoist_bot, :todoist_app_client_secret),
      code: auth_code
    }

    [
      url: "https://todoist.com/oauth/access_token",
      json: body,
      method: :post,
      retry: :transient
    ]
    |> Req.new()
    |> @adapter.request()
  end

  def new(access_token, options \\ []) do
    [
      base_url: "https://api.todoist.com",
      auth: {:bearer, access_token}
    ]
    |> Req.new()
    |> Req.merge(options)
  end

  def request(url, access_token, options \\ []) do
    access_token
    |> new([url: url] ++ options)
    |> @adapter.request()
  end
end
