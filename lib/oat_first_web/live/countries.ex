defmodule OatFirstWeb.Live.Countries do
  use OatFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <h1>Countries</h1>

    <div class="table">
      <table>
        <thead>
          <tr>
            <th :for={col <- @columns}>{col}</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{_id, row} <- @streams.countries}>
            <td :for={col <- @columns}>{row[col]}</td>
          </tr>
        </tbody>
      </table>
    </div>

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
end
