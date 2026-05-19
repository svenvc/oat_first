defmodule OatFirstWeb.Live.Map do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <.map_colocated_hook />
    <div
      id="map"
      class="fullscreen"
      phx-hook=".MapHook"
      phx-update="ignore"
      data-lat={@lat}
      data-lon={@lon}
      data-zoom={@zoom}
    />
    """
  end

  defp map_colocated_hook(assigns) do
    ~H"""
    <script :type={Phoenix.LiveView.ColocatedHook} name=".MapHook">
      export default {
        mounted() {
          this.loadLeaflet(() => this.initMap())
        },
        loadLeaflet(callback) {
          if (typeof L !== "undefined") {
            callback()
            return
          }

          const link = document.createElement("link")
          link.rel = "stylesheet"
          link.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          link.integrity = "sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
          link.crossOrigin = ""
          document.head.appendChild(link)

          const script = document.createElement("script")
          script.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
          script.integrity = "sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
          script.crossOrigin = ""
          script.onload = callback
          document.head.appendChild(script)
        },
        initMap() {
          const el = this.el
          const lat = parseFloat(el.dataset.lat)
          const lon = parseFloat(el.dataset.lon)
          const zoom = parseInt(el.dataset.zoom, 10)

          const map = L.map(el.id).setView([lat, lon], zoom)
          L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          }).addTo(map)
          L.marker([lat, lon]).addTo(map)
        }
      }
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
