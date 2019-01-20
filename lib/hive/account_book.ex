defmodule Hive.AccountBook do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def update_balance(name, address, balance) do
    GenServer.cast(__MODULE__, {:update_balance, name, address, balance})
  end

  def list() do
    GenServer.call(__MODULE__, :list)
  end

  @impl GenServer
  def init(_) do
    {:ok, :ets.new(:account_book, [:set, :protected, :named_table])}
  end

  @impl GenServer
  def handle_cast({:update_balance, name, address, balance}, account_book) do
    :ets.insert(account_book, {name, address, balance})
    {:noreply, account_book}
  end

  @impl GenServer
  def handle_call(:list, _, account_book) do
    {:reply, :ets.tab2list(account_book), account_book}
  end
end
