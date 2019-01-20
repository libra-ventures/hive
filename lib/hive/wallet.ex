defmodule Hive.Wallet do
  alias Hive.{Config, Cli}
  alias Hive.Wallet.Worker

  defdelegate transfer(src_name, dst_name, amount), to: Worker

  @doc "genearate a wallet inside a $HIVE_WALLETS_DIR dir"
  def create() do
    Config.wallets_dir_path()
    |> create()
  end

  def create(dir) do
    name = UUID.uuid4()

    {:ok, output} = Cli.create_wallet(dir, name)
    output |> wallet_info_from() |> Hive.log()
    name
  end

  @doc "Launch a wallet against `wallet` in a $HIVE_WALLETS_DIR dir"
  def open(name) do
    port = get_free_port()
    {:ok, _, _} = Cli.start_wallet_rpc(port, Config.wallet_data_file_path(name))
    {:ok, port}
  end

  defp wallet_info_from(output) do
    ~r/Generated.+\n.+\n/
    |> Regex.run(output)
    |> List.first()
    |> String.trim()
  end

  defp get_free_port() do
    {:ok, listen} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(listen)
    :ok = :gen_tcp.close(listen)
    port
  end
end
