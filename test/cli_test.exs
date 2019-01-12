defmodule Hive.CliTest do
  use ExUnit.Case
  alias Hive.{Cli, Config}
  import Hive.Assertions

  setup do
    [name: UUID.uuid4(), wallets_dir: System.get_env("HIVE_WALLETS_DIR")]
  end

  describe "create_wallet" do
    test "wallet creation", %{wallets_dir: wallets_dir, name: name} do
      assert {:ok, "20" <> _} = Cli.create_wallet(wallets_dir, name)

      assert_wallet_exists(Config.wallet_data_file_path(wallets_dir, name))
    after
      File.rm_rf!(Config.wallet_dir_path(wallets_dir, name))
    end
  end

  describe "start_wallet_rpc" do
    test "starting monero-wallet-rpc for a given wallet", %{wallets_dir: wallets_dir, name: name} do
      port = get_free_port()
      Cli.create_wallet(wallets_dir, name)

      assert {:ok, pid, os_pid} = Cli.start_wallet_rpc(port, Config.wallet_data_file_path(wallets_dir, name))
      assert is_pid(pid)

      wallet_process = :os.cmd('ps xauw | egrep #{os_pid} | egrep -v grep') |> to_string()
      assert String.contains?(wallet_process, "monero-wallet-rpc")

      wallet_params = String.split(wallet_process, "monero-wallet-rpc") |> List.last()

      assert wallet_params ==
               " --testnet --trusted-daemon --wallet-file #{Config.wallet_data_file_path(wallets_dir, name)} --password  --rpc-bind-port #{
                 port
               } --disable-rpc-login --rpc-bind-ip 127.0.0.1\n"
    after
      File.rm_rf!(Config.wallet_dir_path(wallets_dir, name))
    end
  end

  defp get_free_port() do
    {:ok, listen} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(listen)
    :ok = :gen_tcp.close(listen)
    port
  end
end
