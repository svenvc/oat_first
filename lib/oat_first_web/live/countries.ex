defmodule OatFirstWeb.Live.Countries do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Countries</h1>

    <.table
      id="countries"
      rows={@streams.countries}
      row_item={fn {_id, row} -> row end}
      row_click={fn {_id, row} -> JS.navigate(show_on_map(row)) end}
    >
      <:col :let={row} :for={col <- @columns} label={col}>
        {row[col]}
      </:col>
    </.table>

    <div class="align-right mt-6">
      <.oat_theme_toggle />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Countries")
    |> stream_configure(:countries, dom_id: &"country-#{&1["code"]}")
    |> stream(:countries, list_countries())
    |> assign(:columns, ~w(code name capital lat lon))
    |> then(&{:ok, &1})
  end

  defp list_countries() do
    OatFirst.get_countries()
  end

  defp show_on_map(country_data) do
    ~p"/leaflet/map?lon=#{country_data["lon"]}&lat=#{country_data["lat"]}&country=#{country_data["name"]}&capital=#{country_data["capital"]}"
  end
end
