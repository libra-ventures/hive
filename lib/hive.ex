defmodule Hive do
  @doc "print log statements"
  # TODO: add different levels 
  def log(info) do
    IO.inspect(info)
  end
end
