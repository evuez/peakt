defmodule Peakt.Ticker do
  use GenServer
  alias Peakt.Safe


  @interval 1


  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_tick
    {:ok, state}
  end

  def handle_info(:tick, state) do
    Safe.update_all(:safe, :ttl, 0, &(max(&1 - @interval, 0)))

    schedule_tick
    {:noreply, state}
  end

  defp schedule_tick do
    Process.send_after(self, :tick, @interval * 1000)
  end
end
