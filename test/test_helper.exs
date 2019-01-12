Application.stop(:hive)
System.put_env("HIVE_WALLETS_DIR", String.replace_suffix(__ENV__.file, "test_helper.exs", "temp"))
ExUnit.start()
