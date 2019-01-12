defmodule Hive do
  require Logger

  @doc "print log statements"
  # TODO: add different levels 
  def log(info) do
    if Application.get_env(:hive, :debug) do
      Logger.debug(inspect(info))
    end
  end
end
