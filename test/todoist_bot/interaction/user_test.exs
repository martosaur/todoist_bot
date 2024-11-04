defmodule TodoistBot.Interaction.UserTest do
  use ExUnit.Case, async: false

  alias TodoistBot.Interaction.User

  describe ".changeset/2" do
    test "only requires telegram_id" do
      params = %{telegram_id: "1234"}

      assert %{valid?: true} = %User{} |> User.changeset(params)
    end

    test "generates auth_state if doesn't exist" do
      assert %{changes: %{telegram_id: 123, auth_state: "123." <> _}} =
               %User{} |> User.changeset(%{telegram_id: 123})
    end
  end
end
