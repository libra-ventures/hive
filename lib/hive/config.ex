defmodule Hive.Config do
  @doc "Dir where all wallets are stored. Read from $HIVE_WALLETS_DIR"
  @spec wallets_dir_path() :: String.t()
  def wallets_dir_path() do
    os_env!("HIVE_WALLETS_DIR")
  end

  @doc "Dir where wallet files are stored. Equals to $HIVE_WALLET_DIR/$WALLET_NAME"
  @spec wallet_dir_path(String.t()) :: String.t()
  def wallet_dir_path(name), do: wallet_dir_path(wallets_dir_path(), name)

  @spec wallet_dir_path(String.t(), String.t()) :: String.t()
  def wallet_dir_path(dir, name), do: "#{dir}/#{name}"

  @doc "Path to a wallet data file. Defaults to $HIVE_WALLET_DIR/$WALLET_NAME/$WALLET_NAME"
  @spec wallet_data_file_path(String.t()) :: String.t()
  def wallet_data_file_path(name), do: wallets_dir_path() |> wallet_data_file_path(name)

  @spec wallet_data_file_path(String.t(), String.t()) :: String.t()
  def wallet_data_file_path(dir, name), do: "#{dir}/#{name}/#{name}"

  defp os_env!(name) do
    case System.get_env(name) do
      nil -> raise "OS ENV #{name} not set!"
      value -> value
    end
  end
end
