defmodule Hive.Wallet.Worker do
  use GenServer
  alias Hive.Wallet

  def start_link([name, account_book]) do
    GenServer.start_link(__MODULE__, [name, account_book], name: String.to_atom(name))
  end

  def transfer(src_name, address, amount) do
    GenServer.call(String.to_atom(src_name), {:transfer, address, amount})
  end

  @impl GenServer
  def init([name, account_book]) do
    send(self(), :open_wallet)
    {:ok, %{name: name, address: nil, port: nil, account_book: account_book}}
  end

  @impl GenServer
  def handle_info(:open_wallet, %{name: name} = state) do
    {:ok, port} = Wallet.open(name)
    {:ok, %{"address" => address}} = Monero.Wallet.getaddress() |> request(port)

    Process.send_after(self(), :update_account_status, interval())
    {:noreply, %{state | address: address, port: port}}
  end

  @impl GenServer
  def handle_info(:update_account_status, state) do
    {:ok, %{"unlocked_balance" => balance}} = Monero.Wallet.getbalance() |> request(state.port)

    notify_balance_updated(state, balance)
    Process.send_after(self(), :update_account_status, interval())
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:transfer, address, amount}, _from, state) do
    reply =
      case Monero.Wallet.transfer([%{address: address, amount: amount}], ring_size: 1) |> request(state.port) do
        {:ok, reply} ->
          {:ok, reply}

        error ->
          IO.inspect(error,
            label: "transfer failed for #{state.name}/#{state.address} (#{Monero.Wallet.getbalance() |> request(state.port) |> inspect()})"
          )
      end

    {:reply, reply, state}
  end

  defp notify_balance_updated(%{account_book: account_book, name: name, address: address}, balance) do
    account_book.update_balance(name, address, balance)
  end

  defp request(operation, port) do
    wallet_params = %{wallet: %{url: "http://127.0.0.1:#{port}"}}
    Monero.request(operation, wallet_params)
  end

  def interval(), do: 1000 * 60
end
