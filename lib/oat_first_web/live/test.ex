defmodule OatFirstWeb.Live.Test do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <h1>Test</h1>

    <div class="">
      <button phx-click="test-click" class="outline small">Go</button>
      <button phx-click="test-error" class="outline small">Error</button>
    </div>

    <div class="align-right mt-6">
      <.oat_theme_toggle />
    </div>
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
    |> put_flash(:info, "You clicked the Go button @ #{Time.utc_now() |> to_string()}")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("test-error", _unsigned_params, socket) do
    socket
    |> put_flash(:error, "An error occurred @ #{Time.utc_now() |> to_string()}")
    |> then(&{:noreply, &1})
  end
end
