defmodule Hive.TransactionBench do
  alias Hive.{AccountBook, Wallet}

  def run() do
    print_wallets()
    start_wallets() |> wait_until_all_started()
    transfer_loop()
    print_wallets()
  end

  def start_wallets() do
    File.ls!(System.get_env("HIVE_WALLETS_DIR"))
    |> Enum.filter(&(File.stat!(System.get_env("HIVE_WALLETS_DIR") <> "/" <> &1).type == :directory))
    |> Enum.map(&Hive.Wallet.Supervisor.start_child/1)
    |> length()
  end

  def transfer_loop(count \\ 1000)
  def transfer_loop(0), do: IO.inspect(AccountBook.list())

  def transfer_loop(count) do
    wallets = AccountBook.list()

    Enum.each(wallets, fn {name, _, balance} ->
      if balance > 10_000 do
        dsts = Enum.take_random(wallets, 30)
        tx_amount = transaction_amount(balance)

        Enum.each(dsts, fn {_, adress, _} ->
          Wallet.transfer(name, adress, tx_amount)
        end)
      end
    end)
    IO.write(".")
    transfer_loop(count - 1)
  end

  def transaction_amount(balance) do
    amount = div(balance, 50)
    if amount >= 1080, do: 1080, else: amount
  end

  def print_wallets() do
    AccountBook.list() 
    |> Enum.each(fn {name, acc, balance} -> IO.puts "#{name} / #{acc} / #{balance}" end)
  end

  defp wait_until_all_started(count) do
     wait_until_all_started(count, AccountBook.list() |> length())
  end
  defp wait_until_all_started(count, count), do: IO.puts("#{count} wallets started")
  defp wait_until_all_started(count, wallets_started) do
    IO.puts("#{wallets_started} of #{count}  wallets started")
    Process.sleep(1000)
    wait_until_all_started(count)
  end

end
