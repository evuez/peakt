defmodule Peakt.Safe do
  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  def create(safe, key) do
    Agent.update(safe, &Map.put_new(&1, key, %{}))
  end

  def all(safe) do
    Agent.get(safe, &(&1))
  end

  def get(safe, keys, default \\ nil) do
    Agent.get(safe, &get_in(&1, keys)) || default
  end

  def put(safe, keys, value) do
    Agent.update(safe, &put_in(&1, keys, value))
  end

  def update(safe, keys, initial, fun) do
    Agent.update(safe, &update_in(&1, keys, fn (v) -> v && fun.(v) || initial end))
  end

  def update_all(safe, shelf, initial, fun) do
    all(safe)
    |> Map.keys
    |> Enum.each(fn (key) -> update(safe, [key, shelf], initial, fun) end)
  end
end
