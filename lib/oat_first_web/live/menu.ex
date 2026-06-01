defmodule OatFirstWeb.Live.Menu do
  use OatFirstWeb, :live_view

  @links [
    %{title: "Home", path: "/"},
    %{title: "Countries", path: "/countries"},
    %{title: "System Info", path: "/system-info"},
    %{title: "Settings", path: "/settings"},
    %{title: "Test", path: "/test"},
    %{title: "Core Components", path: "/core-components-gallery"},
    %{title: "Map", path: "/leaflet/map"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Menu</h1>

    <div id="menu-links" class="hstack mt-4">
      <.link :for={link <- @links} navigate={link.path} class="button small outline">
        {link.title}
      </.link>
    </div>

    <div class="align-right mt-6">
      <.oat_theme_toggle />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Menu")
    |> assign(:links, @links)
    |> then(&{:ok, &1})
  end
end
