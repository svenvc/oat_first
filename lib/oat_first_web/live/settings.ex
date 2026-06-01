defmodule OatFirstWeb.Live.Settings do
  use OatFirstWeb, :live_view

  require Logger

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
    },
    %{
      key: "number-of-retries",
      type: :integer,
      default: 3,
      min: 0,
      max: 10,
      step: 1,
      title: "Number of Retries",
      description: "How many times to retry a failed request"
    }
  ]

  @impl true
  def render(assigns) do
    ~H"""
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
          <.settings_control
            name={key}
            type={type}
            value={@settings[key]}
            meta={meta}
            error={Map.get(@settings_errors, key)}
          />
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
            <.oat_theme_toggle theme_changed_event="theme-changed" />
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
      <div data-field={@error && "error"}>
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
        <div :if={@error} class="error" role="status">{@error}</div>
      </div>
    </form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> assign(:settings_meta, @settings_meta)
    |> assign(:settings, default_settings())
    |> clear_errors()
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("changed-boolean-" <> key, params, socket) do
    new_value = Map.get(params, "value") == "on"

    socket
    |> update(:settings, fn settings ->
      notify_setting_changed(key, new_value)
      settings |> Map.put(key, new_value)
    end)
    |> clear_errors()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("changed-enum-" <> key, params, socket) do
    new_value = Map.get(params, "value")

    socket
    |> update(:settings, fn settings ->
      notify_setting_changed(key, new_value)
      settings |> Map.put(key, new_value)
    end)
    |> clear_errors()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("changed-string-" <> key, params, socket) do
    new_value = Map.get(params, key)

    socket
    |> update(:settings, fn settings ->
      notify_setting_changed(key, new_value)
      settings |> Map.put(key, new_value)
    end)
    |> clear_errors()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("changed-integer-" <> key, params, socket) do
    new_value = Map.get(params, key)
    meta = socket.assigns.settings_meta |> Enum.find(fn m -> m.key == key end)
    error = evaluate_constraints(meta, new_value)

    socket
    |> update(:settings, fn settings ->
      if int_value = parse_integer(new_value) do
        notify_setting_changed(key, new_value)
        settings |> Map.put(key, int_value)
      else
        settings
      end
    end)
    |> set_error(key, error)
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
        new_value = clamp(meta.min, new_value, meta.max)
        notify_setting_changed(key, new_value)
        new_value
      end)
    end)
    |> clear_errors()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("theme-changed", %{"theme" => theme} = _params, socket) do
    Logger.info("toggle changed theme: #{theme}")

    socket
    |> update(:settings, fn settings -> settings |> Map.put("theme", theme) end)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:setting_changed, "theme", value}, socket) do
    Logger.info("settings changed theme: #{value}")

    socket
    |> push_event("set-theme", %{theme: value})
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:setting_changed, key, value}, socket) do
    Logger.info("setting changed: #{key} = #{value}")

    socket |> then(&{:noreply, &1})
  end

  defp clear_errors(socket) do
    socket |> assign(:settings_errors, %{})
  end

  defp set_error(socket, key, error) do
    socket |> assign(:settings_errors, if(error, do: %{{key, error}}, else: %{}))
  end

  defp notify_setting_changed(key, value) do
    send(self(), {:setting_changed, key, value})
  end

  def clamp(min, value, max) do
    cond do
      value < min -> min
      value > max -> max
      true -> value
    end
  end

  def settings_meta(), do: @settings_meta

  def default_settings() do
    @settings_meta
    |> Enum.into(
      %{},
      fn %{key: key, default: default} -> {key, default} end
    )
  end

  def parse_integer(string, default \\ nil) do
    case Integer.parse(string) do
      {integer, ""} -> integer
      {_integer, _} -> default
      :error -> default
    end
  end

  def evaluate_constraints(%{type: :integer} = meta, value) do
    integer_value = parse_integer(value)

    if is_integer(integer_value) do
      cond do
        integer_value < meta.min -> "Must be larger than #{meta.min}"
        integer_value > meta.max -> "Must be smaller than #{meta.max}"
        # no constraint violation
        true -> nil
      end
    else
      "Enter a valid integer number"
    end
  end

  def evaluate_constraints(_meta, _value) do
    # no constraint violation
    nil
  end
end
