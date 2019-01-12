defmodule Hive.Cli do
  alias Hive.Config

  def create_wallet(dir, name) do
    params = [
      "--generate-new-wallet",
      Config.wallet_data_file_path(dir, name),
      "--password",
      "",
      "--trusted-daemon",
      "--testnet",
      "--allow-mismatched-daemon-version",
      "--mnemonic-language",
      "English",
      "exit"
    ]

    File.mkdir!(Config.wallet_dir_path(name))

    case System.cmd("monero-wallet-cli", params) do
      {output, 0} ->
        {:ok, output}

      cause ->
        File.rmdir!(Config.wallet_dir_path(name))
        {:error, cause}
    end
  end

  def start_wallet_rpc(port, path) do
    :exec.run_link(
      'monero-wallet-rpc --testnet --trusted-daemon --wallet-file #{path} --password "" --rpc-bind-port  #{port} --disable-rpc-login --rpc-bind-ip 127.0.0.1',
      []
    )
  end
end
