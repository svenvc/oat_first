defmodule OatFirstWeb.Live.Map do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div id="map" style="width:100%; height:100vh" />
    <script defer>
      var map = L.map('map').setView([<%= @lon %>, <%= @lat %>], 8);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      }).addTo(map);
      var marker = L.marker([<%= @lon %>, <%= @lat %>]).addTo(map);
    </script>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Map")
    |> assign(:lon, 50.8503)
    |> assign(:lat, 4.3517)
    |> then(&{:ok, &1})
  end
end
