defmodule TodoistBot.Strings do
  @supported_languages [en: "en", pl: "pl", ru: "ru"]

  @strings %{
    authorization_request_text: %{
      "en" => "Please authorize this bot to access your account",
      "pl" => nil,
      "ru" => "Для работы бота нужно авторизоваться"
    },
    authorization_request_button: %{
      "en" => "Authorize on Todoist",
      "pl" => nil,
      "ru" => "Авторизоваться на Todoist"
    },
    settings_button: %{
      "en" => "Settings",
      "pl" => nil,
      "ru" => "Настройки"
    },
    task_added_text: %{
      "en" => "Task added",
      "pl" => nil,
      "ru" => "Задача добавлена"
    },
    redirecting_web: %{
      "en" => "You're being redirected...",
      "pl" => nil,
      "ru" => "Перенаправляем..."
    },
    authorization_success_text: %{
      "en" =>
        "You have been succesfully authorized! Now simply drop me a message to create a new task",
      "pl" => nil,
      "ru" =>
        "Авторизация прошла успешно. Теперь просто пришлите мне сообщение, чтобы создать новую задачу."
    },
    authorization_success_web: %{
      "en" => "You have been succesfully authorized.",
      "pl" => nil,
      "ru" => "Авторизация прошла успешно."
    },
    language_changed: %{
      "en" => "Language successfully changed.",
      "pl" => nil,
      "ru" => "Язык успешно изменен."
    },
    settings_menu_text: %{
      "en" => "Language settings",
      "pl" => nil,
      "ru" => "Настройки языка"
    },
    help_text: %{
      "en" =>
        "/help - show this help\n/settings - change language\n/about - about this bot\n/logout - make this bot forget you",
      "pl" => nil,
      "ru" =>
        "/help - показать эту справку\n/settings - выбрать язык\n/about - информация о боте\n/logout - стереть вас из памяти этого бота"
    },
    about_text: %{
      "en" =>
        "*Telegram for Todoist* is a simple bot for adding Inbox tasks through Telegram. This bot is created by @martosaur and is not created by, affiliated with, or supported by Doist. If you want to contribute please see [this repo](https://github.com/martosaur/todoist_bot)",
      "pl" => nil,
      "ru" =>
        "*Telegram for Todoist* – это простой бот, добавляющий входящие задачи в Todoist через телеграм. Этот бот создан @martosaur и не создан, связан или поддерживается компанией Doist. Поучаствовать в разработке можно в [этом репозитории](https://github.com/martosaur/todoist_bot)"
    },
    logout_confirm_text: %{
      "en" =>
        "Are you sure you want to logout and disappear without a trace from this bot's life?",
      "pl" => nil,
      "ru" => "Вы уверeны, что хотите заставить бота забыть о вашем существовании?"
    },
    logout_confirm_yes_button: %{
      "en" => "Yes",
      "pl" => "Tak",
      "ru" => "Да"
    },
    logout_success_text: %{
      "en" => "Who are you? Do I know you?",
      "pl" => nil,
      "ru" => "Кто вы? Мы знакомы?"
    },
    add_task_error_text: %{
      "en" => "Something went terribly wrong 😢 Let's maybe try again?",
      "pl" => nil,
      "ru" => "Что-то пошло не так 😢 Может попробуем еще раз?"
    },
    back: %{
      "en" => "<<"
    },
    en: %{
      "en" => "🇬🇧 English"
    },
    ru: %{
      "en" => "🇷🇺 Русский"
    },
    pl: %{
      "en" => "🇵🇱 Polski"
    },
    test: %{
      "en" => "default_test",
      "pl" => nil,
      "ru" => "тест"
    }
  }

  def get_string(id, language) do
    case @strings[id][language] do
      nil ->
        @strings[id]["en"] || ""

      s ->
        s
    end
  end

  def get_supported_languages(), do: @supported_languages
end
