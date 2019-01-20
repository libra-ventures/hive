defmodule Hive.Wallet.Supervisor do
  use DynamicSupervisor
  alias Hive.AccountBook

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(name) do
    spec = {Hive.Wallet.Worker, [name, AccountBook]}
    DynamicSupervisor.start_child(Hive.Wallet.Supervisor, spec)
  end
end
