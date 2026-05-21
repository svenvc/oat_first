# Single file Phoenix LiveView Counter example

require Logger

Logger.info("Running single file Phoenix LiveView Counter example")

defmodule Counter.Random do
  def string(count) do
    Stream.repeatedly(fn -> Enum.random(?A..?Z) end) |> Enum.take(count) |> List.to_string()
  end
end

Application.put_env(:counter, Counter.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5050],
  server: true,
  live_view: [signing_salt: Counter.Random.string(8)],
  secret_key_base: Counter.Random.string(64)
)

Mix.install([
  {:plug_cowboy, "~> 2.5"},
  {:jason, "~> 1.2"},
  {:phoenix, "~> 1.8.1"},
  {:phoenix_live_view, "~> 1.1.0"}
])

defmodule Counter.ErrorView do
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule Counter.HomeLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  defp phx_vsn, do: Application.spec(:phoenix, :vsn)
  defp lv_vsn, do: Application.spec(:phoenix_live_view, :vsn)

  def render("html.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <title>Counter</title>
        <script src={"https://cdn.jsdelivr.net/npm/phoenix@#{phx_vsn()}/priv/static/phoenix.min.js"} />
        <script src={"https://cdn.jsdelivr.net/npm/phoenix_live_view@#{lv_vsn()}/priv/static/phoenix_live_view.min.js"} />
        <script>
          let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
          liveSocket.connect()
        </script>
        <link rel="stylesheet" href="https://unpkg.com/@knadh/oat/oat.min.css" />
        <script src="https://unpkg.com/@knadh/oat/oat.min.js" defer />
        <style>
          body { display: flex; justify-content: center; margin: 2em; color-scheme: dark; }
          .w1 { width: 1em; }
        </style>
      </head>
      <body>
        {@inner_content}
      </body>
    </html>
    """
  end

  def render(assigns) do
    ~H"""
    <article class="card">
      <header>
        <h1>Counter</h1>
      </header>
      <div class="hstack mt-6">
        <button phx-click="dec">-</button>
        <div class="w1 align-center">{@count}</div>
        <button phx-click="inc">+</button>
      </div>
      <footer class="mt-6">A number between 0 and 9</footer>
    </article>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :count, fn count -> min(count + 1, 9) end)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :count, fn count -> max(count - 1, 0) end)}
  end
end

defmodule Counter.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:put_root_layout, {Counter.HomeLive, :html})
  end

  scope "/", Counter do
    pipe_through(:browser)

    live "/", HomeLive, :index
  end
end

defmodule Counter.Endpoint do
  use Phoenix.Endpoint, otp_app: :counter

  socket("/live", Phoenix.LiveView.Socket)
  plug(Counter.Router)
end

{:ok, _} = Supervisor.start_link([Counter.Endpoint], strategy: :one_for_one)

apps = Application.started_applications() |> Enum.map(fn {name, _, _} -> name end)

Logger.info("Started applications #{inspect(apps)}")

Process.sleep(:infinity)
