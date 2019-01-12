defmodule Hive.Assertions do
  import ExUnit.Assertions, only: [assert: 1, assert: 2]

  def assert_wallet_exists(wallet_data_file_path) do
    assert File.exists?(wallet_data_file_path)
    assert File.exists?(wallet_data_file_path <> ".address.txt")
    assert File.exists?(wallet_data_file_path <> ".keys")
  end

  def assert_wallet_rpc_started(key, wallet, port) do
    wallet_process = :os.cmd('ps xauw | egrep #{key} | egrep -v grep') |> to_string()
    assert String.contains?(wallet_process, "monero-wallet-rpc")

    wallet_params = String.split(wallet_process, "monero-wallet-rpc") |> List.last()

    assert wallet_params ==
             " --testnet --trusted-daemon --wallet-file #{wallet} --password  --rpc-bind-port #{port} --disable-rpc-login --rpc-bind-ip 127.0.0.1\n"
  end
end
