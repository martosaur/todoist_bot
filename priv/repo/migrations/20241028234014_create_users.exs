defmodule TodoistBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :telegram_id, :id, primary_key: true
      add :last_chat_id, :integer
      add :auth_code, :string
      add :auth_state, :string
      add :access_token, :string
      add :delete, :boolean, default: false, null: false
      add :raw, :map, default: "{}"
      
      timestamps(type: :utc_datetime)
    end
  end
end
