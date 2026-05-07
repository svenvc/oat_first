defmodule OatFirstWeb.Live.Map do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />
    <div id="map" class="fullscreen" />
    <script defer>
      var map = L.map('map').setView([<%= @lat %>, <%= @lon %>], <%= @zoom %>);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      }).addTo(map);
      var marker = L.marker([<%= @lat %>, <%= @lon %>]).addTo(map);
    </script>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    lon = to_float(Map.get(params, "lon"), 4.3517)
    lat = to_float(Map.get(params, "lat"), 50.8503)
    country = Map.get(params, "country", "Belgium")
    capital = Map.get(params, "capital", "Brussels")

    socket
    |> assign(:page_title, "#{capital}, #{country}")
    |> assign(:lon, lon)
    |> assign(:lat, lat)
    |> assign(:zoom, adjust_zoom_for_latitude(8, lat))
    |> then(&{:ok, &1})
  end

  defp to_float(input, default) when is_nil(input) and is_float(default), do: default

  defp to_float(input, default) when is_binary(input) and is_float(default) do
    try do
      String.to_float(input)
    rescue
      ArgumentError -> default
    end
  end

  defp adjust_zoom_for_latitude(base_zoom, latitude) do
    lat_rad = latitude * :math.pi() / 180
    adjustment = :math.log2(:math.cos(lat_rad))
    rounded_adjustment = Float.round(adjustment, 0) |> Kernel.trunc()
    base_zoom + rounded_adjustment
  end
end
