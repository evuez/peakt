defmodule Peakt.PageController do
  use Peakt.Web, :controller
  alias Peakt.Token

  def index(conn, _params) do
    redirect conn, to: page_path(conn, :peakt, Token.new)
  end

  def peakt(conn, %{"token" => token}) do
    conn
    |> assign(:room_token, token)
    |> render("peakt.html")
  end
end
