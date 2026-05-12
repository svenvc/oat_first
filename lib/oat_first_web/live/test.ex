defmodule OatFirstWeb.Live.Test do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Test</h1>
    <p><button phx-click="test-click">Go</button></p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Test")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("test-click", _unsigned_params, socket) do
    socket
    |> put_flash(:info, "You clicked the Go button")
    |> then(&{:noreply, &1})
  end
end
