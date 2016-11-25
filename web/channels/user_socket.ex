defmodule Peakt.UserSocket do
  use Phoenix.Socket
  alias Peakt.Token

  ## Channels
  channel "room:*", Peakt.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000

  def connect(_params, socket) do
    {:ok, assign(socket, :uid, Token.new(10))}
  end

  def id(socket), do: "users_socket:#{socket.assigns.uid}"
end
