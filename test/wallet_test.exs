defmodule Hive.WalletTest do
  use ExUnit.Case
  alias Hive.{Config, Wallet}
  import Hive.Assertions

  setup do
    [name: UUID.uuid4(), wallets_dir: System.get_env("HIVE_WALLETS_DIR")]
  end

  describe "create" do
    test "with dir name", %{wallets_dir: wallets_dir, name: name} do
      nested_dir = Path.join(wallets_dir, name)
      File.mkdir!(nested_dir)

      name = Wallet.create(nested_dir)
      assert_wallet_exists(Config.wallet_data_file_path(nested_dir, name))
    after
      File.rm_rf!(Path.join(wallets_dir, name))
    end

    test "without dir name (dir is read from $HIVE_WALLETS_DIR)", %{wallets_dir: wallets_dir} do
      name = Wallet.create()
      assert_wallet_exists(Config.wallet_data_file_path(wallets_dir, name))

      File.rm_rf!(Path.join(wallets_dir, name))
    end
  end

  describe "open" do
    test "starting monero-wallet-rpc for a given wallet", %{wallets_dir: wallets_dir, name: name} do
      assert {:ok, port} = Wallet.open(name)
      assert_wallet_rpc_started("monero-wallet-rpc", Config.wallet_data_file_path(name), port)
    after
      File.rm_rf!(Config.wallet_dir_path(wallets_dir, name))
    end
  end
end
