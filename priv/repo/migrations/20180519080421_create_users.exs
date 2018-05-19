defmodule TodoistBot.Storage.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:telegram_id, :integer)
      add(:last_chat_id, :integer)
      add(:auth_code, :string)
      add(:auth_state, :string)
      add(:access_token, :string)
      add(:language, :string)

      timestamps()
    end
  end
end
