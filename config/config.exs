# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :peakt, Peakt.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4Jx6kzVoQCA9R7r98e8+4oPnPKFgxU3iIOjCg9RB6In4Dt8WmwmVxeW3tWi66hMh",
  render_errors: [view: Peakt.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Peakt.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
