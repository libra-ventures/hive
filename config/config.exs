use Mix.Config

config :monero,
  json_codec: Jason,
  retries: [
    max_attempts: 50,
    base_backoff_in_ms: 10,
    max_backoff_in_ms: 50_000
  ]

import_config "#{Mix.env()}.exs"
