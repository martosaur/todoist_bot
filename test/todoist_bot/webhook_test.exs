defmodule TodoistBotTest.Webhook do
  use ExUnit.Case, async: true
  
  import Mox
  
  alias TodoistBot.Webhook
  alias TodoistBot.Nadia.API
  
  setup :verify_on_exit!
  
  def allow_supervisor(test_pid) do
    allow(API.Mock, test_pid, self()) 
    
    :ignore
  end
  
  describe "delete webhook" do
    test "deletes webhook and exits" do
      test_pid = self()
      
      children = [
        %{
          id: Allow,
          start: {__MODULE__, :allow_supervisor, [test_pid]}
        },
        %{
          id: Foo,
          start: {Webhook, :delete_webhook, []}
        }
      ]
      
      expect(API.Mock, :delete_webhook, fn -> :ok end)
  
      {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
    end
    
    test "shuts down supervisor on error" do
      test_pid = self()
      
      children = [
        %{
          id: Allow,
          start: {__MODULE__, :allow_supervisor, [test_pid]}
        },
        %{
          id: Foo,
          start: {Webhook, :delete_webhook, []}
        }
      ]
      
      expect(API.Mock, :delete_webhook, fn -> {:error, :api_error} end)
      
      Process.flag(:trap_exit, true)
      assert {:error, {:shutdown, {:failed_to_start_child, Foo, :api_error}}} = Supervisor.start_link(children, strategy: :one_for_one)
    end
  end

  describe "setup webhook" do
    test "sets up webhook if" do
      test_pid = self()
      
      children = [
        %{
          id: Allow,
          start: {__MODULE__, :allow_supervisor, [test_pid]}
        },
        %{
          id: Foo,
          start: {Webhook, :setup_webhook, []}
        }
      ]
      
      expect(API.Mock, :set_webhook, fn opts ->
        assert [url: "https://localhost/secret_token", max_connections: 40] = opts
        
        :ok
      end)
  
      {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
    end
    
    test "shuts down supervisor on error" do
      test_pid = self()
      
      children = [
        %{
          id: Allow,
          start: {__MODULE__, :allow_supervisor, [test_pid]}
        },
        %{
          id: Foo,
          start: {Webhook, :setup_webhook, []}
        }
      ]
      
      expect(API.Mock, :set_webhook, fn _ -> {:error, :api_error} end)
      
      Process.flag(:trap_exit, true)
      assert {:error, {:shutdown, {:failed_to_start_child, Foo, :api_error}}} = Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
end