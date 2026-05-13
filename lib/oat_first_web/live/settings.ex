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
    },
    %{
      key: "theme",
      type: :enum,
      enum: ~w(system light dark),
      default: "system",
      title: "UI Theme",
      description: "Choose the UI theme, a selected static one, or follow the system configuration"
    },
    %{
      key: "font-family",
      type: :enum,
      enum: ["system", "Helvetica Neu", "Monaco", "Lucida Grande", "Open Sans Code"],
      default: "",
      title: "Font Family",
      description: "Choose the font family for the text editor, or follow the system configuration"
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
        </div>
      </div>

      <div
        :for={
          %{key: key, type: type, title: title, description: description} = meta <- @settings_meta
        }
        class="row mt-4"
      >
        <div class="col-4 offset-3">
          <div class="bold">{title}</div>
          <div class="text-smaller text-light">{description}</div>
        </div>
        <div class="col-2 align-right">
          <.settings_control name={key} type={type} value={@settings[key]} meta={meta} />
        </div>
      </div>

      <br />

      <div class="row mt-6">
        <div class="col-6 offset-3">
          <h1>Values</h1>
          <div class="table">
            <table>
              <thead>
                <tr>
                  <th>key</th>
                  <th>type</th>
                  <th>value</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={%{key: key, type: type} <- @settings_meta}>
                  <td>{key}</td>
                  <td>{type}</td>
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

  defp settings_control(%{type: :boolean} = assigns) do
    ~H"""
    <input type="checkbox" role="switch" name={@name} checked={@value} phx-click={"changed-boolean-#{@name}"} />
    """
  end

  defp settings_control(%{type: :enum} = assigns) do
    ~H"""
    <form>
      <select phx-change={"changed-enum-#{@name}"} name="value">
        <option :for={enum <- @meta.enum} value={enum}>{enum}</option>
      </select>
    </form>
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

  @impl true
  def handle_event("changed-boolean-" <> key, params, socket) do
    socket
    |> update(:settings, fn settings ->
      settings |> Map.put(key, Map.get(params, "value") == "on")
    end)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("changed-enum-" <> key, params, socket) do
    socket
    |> update(:settings, fn settings ->
      settings |> Map.put(key, Map.get(params, "value"))
    end)
    |> then(&{:noreply, &1})
  end

  def settings_meta(), do: @settings_meta

  def default_settings() do
    @settings_meta |> Enum.into(%{}, fn %{key: key, default: default} -> {key, default} end)
  end
end
