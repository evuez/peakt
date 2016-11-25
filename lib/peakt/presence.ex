defmodule Peakt.Presence do
  use Phoenix.Presence, otp_app: :peakt, pubsub_server: Peakt.PubSub
end
