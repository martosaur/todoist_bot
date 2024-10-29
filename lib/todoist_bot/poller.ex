defmodule TodoistBot.Poller do
  use Broadway

  def start_link(bot_token) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {OffBroadway.Telegram.Producer,
           [client: {OffBroadway.Telegram.ReqClient, [token: bot_token]}]},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 2]
      ]
    )
  end

  @impl Broadway
  def handle_message(
        _processor,
        %Broadway.Message{
          data: update
        } = message,
        _context
      ) do
    TodoistBot.Processor.process_message(update)

    message
  end
end
