defmodule OatFirstWeb.Live.Test do
  use OatFirstWeb, :live_view

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <h1>{@page_title}</h1>

    <div class="hstack">
      <button phx-click="test-click" class="outline small">
        {dgettext("app", "Go")}
      </button>
      <button phx-click="test-error" class="outline small">
        {dgettext("app", "Error")}
      </button>
      <button phx-click="test-ping" class="outline small">
        {dgettext("app", "Ping")}
      </button>
    </div>

    <div class="flex justify-end mt-6">
      <div class="hstack">
        <.oat_theme_toggle />
        <.locale_selector locale={@locale} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _uri, socket) do
    locale = Map.get(params, "locale", Gettext.get_locale(OatFirstWeb.Gettext))

    if locale in Gettext.known_locales(OatFirstWeb.Gettext) do
      Gettext.put_locale(OatFirstWeb.Gettext, locale)

      socket
      |> assign(:page_title, dgettext("app", "Test"))
      |> assign(:locale, locale)
    else
      socket
    end
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("test-click", _params, socket) do
    now = Time.utc_now() |> to_string()
    msg = dgettext("app", "You clicked the Go button")

    socket
    |> put_flash(:info, "#{msg} @ #{now}")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("test-error", _params, socket) do
    now = Time.utc_now() |> to_string()
    msg = dgettext("app", "An error occurred")

    socket
    |> put_flash(:error, "#{msg} @ #{now}")
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("test-ping", _params, socket) do
    socket
    |> clear_flash()
    |> put_flash(:info, "Pong")
    |> put_flash(:time, Time.utc_now() |> to_string())
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("locale-changed", %{"locale" => locale}, socket) do
    if locale in Gettext.known_locales(OatFirstWeb.Gettext) do
      Logger.info("Switching locale to #{locale}")
      Gettext.put_locale(OatFirstWeb.Gettext, locale)

      socket
      |> push_navigate(to: ~p"/test?locale=#{locale}")
    else
      socket
    end
    |> then(&{:noreply, &1})
  end
end
