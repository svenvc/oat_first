defmodule OatFirstWeb.Live.Test do
  use OatFirstWeb, :live_view

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <h1>{@page_title}</h1>

    <div class="hstack">
      <button phx-click="test-click" class="outline small">{@locale && dgettext("app", "Go")}</button>
      <button phx-click="test-error" class="outline small">
        {@locale && dgettext("app", "Error")}
      </button>
    </div>

    <div class="flex justify-end mt-6">
      <div class="hstack">
        <.oat_theme_toggle />
        <.locale_selector />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, dgettext("app", "Test"))
    |> assign(:locale, Gettext.get_locale(OatFirstWeb.Gettext))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("test-click", _unsigned_params, socket) do
    socket
    |> put_flash(
      :info,
      "#{dgettext("app", "You clicked the Go button")} @ #{Time.utc_now() |> to_string()}"
    )
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("test-error", _unsigned_params, socket) do
    socket
    |> put_flash(
      :error,
      "#{dgettext("app", "An error occurred")} @ #{Time.utc_now() |> to_string()}"
    )
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("locale-changed", %{"locale" => locale}, socket) do
    if locale in Gettext.known_locales(OatFirstWeb.Gettext) do
      Logger.info("Switching locale to #{locale}")
      Gettext.put_locale(OatFirstWeb.Gettext, locale)

      socket
      |> assign(:locale, locale)
      |> assign(:page_title, dgettext("app", "Test"))
    else
      socket
    end
    |> then(&{:noreply, &1})
  end
end
