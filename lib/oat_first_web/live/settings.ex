defmodule OatFirstWeb.Live.Settings do
  use OatFirstWeb, :live_view

  @settings_meta [
    %{
      key: "debug-mode",
      type: :boolean,
      default: false,
      title: "Enable Debug Mode",
      description: "Whether to enable extra debugging features and more verbose logging"
    },
    %{
      key: "enable-lsp",
      type: :boolean,
      default: true,
      title: "Enable Language Server",
      description: "Whether to use language servers to enable code intelligence"
    }
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="container mt-6">
      <div class="row">
        <div class="col-6 offset-3">
          <h1>Settings</h1>

          <div class="table">
            <table>
              <tbody>
                <tr :for={%{key: key} <- @settings_meta}>
                  <td>{key}</td>
                  <td>{@settings[key]}</td>
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
    |> assign(:page_title, "Settings")
    |> assign(:settings_meta, @settings_meta)
    |> assign(:settings, default_settings())
    |> then(&{:ok, &1})
  end

  def default_settings() do
    @settings_meta |> Enum.into(%{}, fn %{key: key, default: default} -> {key, default} end)
  end
end
