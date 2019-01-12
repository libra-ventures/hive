defmodule Hive.Wallet.Worker do
  use GenServer
  alias Hive.Wallet

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: String.to_atom(name))
  end

  @impl GenServer
  def init(name) do
    send(self(), :open_wallet)
    {:ok, {name, nil}}
  end

  @impl GenServer
  def handle_info(:open_wallet, {name, nil}) do
    {:ok, port} = Wallet.open(name)

    {:noreply, {name, port}}
  end
end
