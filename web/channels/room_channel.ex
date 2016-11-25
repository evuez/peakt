defmodule Peakt.RoomChannel do
  use Peakt.Web, :channel
  alias Peakt.Presence
  alias Peakt.Safe

  @default_ttl 2
  @reward 2
  @penalty -1

  def join("room:" <> token, _payload, socket) do
    create_safe(token)
    track_presence
    schedule_pick

    socket = assign(socket, :token, token)

    {:ok, %{"pick" => get_pick(token), "winner" => has_current_won?(socket)}, socket}
  end

  def handle_in("menu", %{"items" => items}, socket) do
    store_items(socket.assigns.token, items)
    {:noreply, socket}
  end

  def handle_in("vote", %{"dir" => "up"}, socket) do
    incr_votes(socket.assigns.token)
    {:noreply, socket}
  end
  def handle_in("vote", %{"dir" => "down"}, socket) do
    decr_votes(socket.assigns.token)
    {:noreply, socket}
  end

  def handle_info(:pick, socket) do
    token = socket.assigns.token

    pick = case has_current_won?(socket) do
      true  -> {:old, get_pick(token), true}
      false -> grab_pick(token)
    end

    case pick do
      {:new, pick} ->
        reset_votes(token)
        broadcast!(socket, "pick", %{"pick" => pick})
      {:old, pick, true} ->
        broadcast!(socket, "pick", %{"pick" => pick, "winner" => true})
      {:old, _} -> nil
    end

    schedule_pick

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.uid, %{
      online_at: inspect(System.system_time(:seconds))
    })
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  defp schedule_pick, do: Process.send_after(self, :pick, 1000)

  # Presence

  defp track_presence, do: send(self, :after_join)

  defp presence_count(socket) do
    socket
    |> Presence.list
    |> Map.keys
    |> Enum.count
  end

  # Safe

  defp create_safe(token), do: Safe.create(:safe, token)

  # Items

  defp store_items(token, items) do
    items = String.split(items, ",") |> Enum.filter(fn s -> String.trim(s) != "" end)

    case items do
      [] -> nil
      _  -> Safe.update(:safe, [token, :items], items, &(&1 ++ items))
    end
  end

  defp get_items(token), do: Safe.get(:safe, [token, :items], [nil])

  # Pick

  defp grab_pick(token) do
    case get_ttl(token) do
      0 -> {:new, random_pick(token)}
      _ -> {:old, get_pick(token)}
    end
  end

  defp random_pick(token) do
    pick = get_items(token) |> Enum.random
    set_pick(token, pick)
    set_ttl(token, @default_ttl)
    pick
  end

  defp get_pick(token), do: Safe.get(:safe, [token, :pick])

  defp set_pick(token, pick), do: Safe.put(:safe, [token, :pick], pick)

  # TTL

  defp get_ttl(token), do: Safe.get(:safe, [token, :ttl], 0)

  defp set_ttl(token, seconds), do: Safe.put(:safe, [token, :ttl], seconds)

  defp update_ttl(token, seconds), do: Safe.update(:safe, [token, :ttl], 0, &(&1 + seconds))

  # Votes

  defp incr_votes(token) do
    update_ttl(token, @reward)
    Safe.update(:safe, [token, :votes], 1, &(&1 + 1))
  end

  defp decr_votes(token) do
    update_ttl(token, @penalty)
    Safe.update(:safe, [token, :votes], 0, fn c -> max(0, c - 1) end)
  end

  defp get_votes(token), do: Safe.get(:safe, [token, :votes], 0)

  defp reset_votes(token), do: Safe.put(:safe, [token, :votes], 0)

  defp has_current_won?(socket) do
    votes = get_votes(socket.assigns.token)
    presences = presence_count(socket)

    votes > presences / 2
  end
end
