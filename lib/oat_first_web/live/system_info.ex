defmodule OatFirstWeb.Live.SystemInfo do
  use OatFirstWeb, :live_view

  @fields [
    {"App", :application},
    {"Version", :application_version},
    {"Elixir", :elixir_version},
    {"OTP", :otp_version},
    {"ERTS", :erts_version},
    {"Phoenix", :phoenix_version},
    {"Memory", :total_memory_human_readable},
    {"Uptime", :uptime_human_readable}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="container mt-6">
      <div class="row">
        <div class="col-6 offset-3">
          <h1>System Information</h1>

          <div class="table">
            <table>
              <tbody>
                <tr :for={{label, field} <- @fields}>
                  <td>{label}</td>
                  <td>{@system_info[field]}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="align-right mt-6">
            <.refresh_button />
            <.oat_theme_toggle />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp refresh_button(assigns) do
    ~H"""
    <button phx-click="refresh" class="outline small">
      <svg
        width="16"
        height="16"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
        />
      </svg>
    </button>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "System Info")
    |> assign(:system_info, get_system_info())
    |> assign(:fields, @fields)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("refresh", _unsigned_params, socket) do
    socket
    |> assign(:system_info, get_system_info())
    |> put_flash(:info, "System information was updated")
    |> put_flash(:time, System.os_time())
    |> then(&{:noreply, &1})
  end

  defp get_system_info() do
    OatFirst.get_system_info()
  end
end
