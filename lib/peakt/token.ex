defmodule Peakt.Token do
  def new(length \\ 32) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
