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
      description:
        "Choose the UI theme, a selected static one, or follow the system configuration"
    },
    %{
      key: "font-family",
      type: :enum,
      enum: ["system", "Helvetica Neu", "Monaco", "Lucida Grande", "Open Sans Code"],
      default: "Monaco",
      title: "Font Family",
      description:
        "Choose the font family for the text editor, or follow the system configuration"
    },
    %{
      key: "api-key",
      type: :string,
      default: "",
      title: "API Key",
      description: "The HTTP bearer token to access the remote REST API"
    },
    %{
      key: "max-load",
      type: :integer,
      default: 100,
      min: 20,
      max: 100,
      step: 10,
      title: "Maximum Load",
      description: "Percentage of CPU load allowed before trottling down"
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
    <input
      type="checkbox"
      role="switch"
      name={@name}
      checked={@value}
      phx-click={"changed-boolean-#{@name}"}
    />
    """
  end

  defp settings_control(%{type: :enum} = assigns) do
    ~H"""
    <form>
      <select phx-change={"changed-enum-#{@name}"} name="value">
        <option :for={enum <- @meta.enum} value={enum} selected={@value == enum}>{enum}</option>
      </select>
    </form>
    """
  end

  defp settings_control(%{type: :string} = assigns) do
    ~H"""
    <form>
      <input
        type="text"
        name={@name}
        placeholder="XXXX-YYYY-ZZZZ"
        phx-change={"changed-string-#{@name}"}
        phx-debounce
        value={@value}
      />
    </form>
    """
  end

  defp settings_control(%{type: :integer} = assigns) do
    ~H"""
    <form>
      <fieldset class="group">
        <button type="button" phx-click={"change-integer-#{@name}"} phx-value-step={-@meta.step}>
          -
        </button>
        <input
          type="text"
          name={@name}
          phx-change={"changed-integer-#{@name}"}
          phx-debounce
          value={@value}
          class="align-center"
        />
        <button type="button" phx-click={"change-integer-#{@name}"} phx-value-step={@meta.step}>
          +
        </button>
      </fieldset>
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

  @impl true
  def handle_event("changed-string-" <> key, params, socket) do
    socket
    |> update(:settings, fn settings ->
      settings |> Map.put(key, Map.get(params, key))
    end)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("changed-integer-" <> key, params, socket) do
    socket
    |> update(:settings, fn settings ->
      value = Map.get(params, key)

      if is_integer(parse_integer(value)) do
        settings |> Map.put(key, parse_integer(Map.get(params, key), 0))
      else
        settings
      end
    end)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("change-integer-" <> key, params, socket) do
    socket
    |> update(:settings, fn settings ->
      step = parse_integer(Map.get(params, "step"), 0)

      settings
      |> Map.update(key, 0, fn value ->
        new_value = value + step
        meta = socket.assigns.settings_meta |> Enum.find(fn m -> m.key == key end)

        cond do
          new_value < meta.min -> meta.min
          new_value > meta.max -> meta.max
          true -> new_value
        end
      end)
    end)
    |> then(&{:noreply, &1})
  end

  def settings_meta(), do: @settings_meta

  def default_settings() do
    @settings_meta |> Enum.into(%{}, fn %{key: key, default: default} -> {key, default} end)
  end

  defp parse_integer(string, default \\ nil) do
    case Integer.parse(string) do
      {integer, _} -> integer
      :error -> default
    end
  end
end
