defmodule OatFirstWeb.Live.SystemInfo do
  use OatFirstWeb, :live_view

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
              <thead>
                <tr>
                  <th>key</th>
                  <th>value</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>App</td>
                  <td>{@system_info.application}</td>
                </tr>
                <tr>
                  <td>Version</td>
                  <td>{@system_info.application_version}</td>
                </tr>
                <tr>
                  <td>Elixir</td>
                  <td>{@system_info.elixir_version}</td>
                </tr>
                <tr>
                  <td>OTP</td>
                  <td>{@system_info.otp_version}</td>
                </tr>
                <tr>
                  <td>ERTS</td>
                  <td>{@system_info.erts_version}</td>
                </tr>
                <tr>
                  <td>Phoenix</td>
                  <td>{@system_info.phoenix_version}</td>
                </tr>
                <tr>
                  <td>Memory</td>
                  <td>{@system_info.total_memory_human_readable}</td>
                </tr>
                <tr>
                  <td>Uptime</td>
                  <td>{@system_info.uptime_human_readable}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="align-right mt-6">
            <.oat_theme_toggle />
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "System Info")
    |> assign(:system_info, get_system_info())
    |> then(&{:ok, &1})
  end

  defp get_system_info() do
    OatFirst.get_system_info()
  end
end
