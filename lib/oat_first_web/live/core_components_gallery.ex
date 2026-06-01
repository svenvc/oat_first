defmodule OatFirstWeb.Live.CoreComponentsGallery do
  use OatFirstWeb, :live_view

  @sample_rows [
    %{name: "Alice", email: "alice@example.com", role: "Admin"},
    %{name: "Bob", email: "bob@example.com", role: "Editor"},
    %{name: "Carol", email: "carol@example.com", role: "Viewer"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <h1>Core Components Gallery</h1>

    <p>
      Using <a href="https://oat.ink">Oat</a>, an ultra-lightweight HTML + CSS, semantic UI component library with zero dependencies.
    </p>

    <h2>Button</h2>
    <div class="hstack">
      <.button>Default</.button>
      <.button variant="primary">Primary</.button>
      <.button class="outline">Outline</.button>
      <.button class="ghost">Ghost</.button>
      <.button class="small">Small</.button>
      <.button class="large">Large</.button>
      <.button disabled>Disabled</.button>
      <.button navigate={~p"/"}>As link</.button>
    </div>

    <h2>Input (text)</h2>
    <div class="vstack">
      <.input type="text" name="demo-text" value="Default value" />
      <.input type="text" name="demo-text-pl" value="" placeholder="Placeholder text" />
      <.input type="text" name="demo-text-err" value="Bad" errors={["Must be at least 3 characters"]} />
    </div>

    <h2>Input (email)</h2>
    <div class="vstack">
      <.input type="email" name="demo-email" value="user@example.com" label="Email" />
      <.input
        type="email"
        name="demo-email-err"
        value="not-an-email"
        label="Email"
        errors={["Enter a valid email address"]}
      />
    </div>

    <h2>Input (checkbox)</h2>
    <div class="vstack">
      <.input type="checkbox" name="demo-cb-1" label="Subscribe to newsletter" />
      <.input type="checkbox" name="demo-cb-2" label="Remember me" checked />
    </div>

    <h2>Input (select)</h2>
    <div class="vstack">
      <.input
        type="select"
        name="demo-sel"
        value=""
        label="Role"
        options={["Admin", "Editor", "Viewer"]}
        prompt="Choose a role"
      />
      <.input
        type="select"
        name="demo-sel-err"
        value=""
        label="Role"
        options={[]}
        prompt="Choose a role"
        errors={["This field is required"]}
      />
    </div>

    <h2>Input (textarea)</h2>
    <div class="vstack">
      <.input type="textarea" name="demo-ta" value="Some content" label="Description" />
      <.input
        type="textarea"
        name="demo-ta-err"
        value=""
        label="Description"
        errors={["Can't be blank"]}
      />
    </div>

    <h2>Flash</h2>
    <div class="hstack">
      <button phx-click="flash-info" class="outline small">Info Flash</button>
      <button phx-click="flash-error" class="outline small">Error Flash</button>
    </div>
    <div class="hstack mt-4">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>

    <h2>Header</h2>
    <.header>Simple Header</.header>
    <.header>
      Header with subtitle
      <:subtitle>This is a subtitle describing the section</:subtitle>
    </.header>
    <.header>
      Header with actions
      <:actions>
        <.button class="small">Action</.button>
      </:actions>
    </.header>

    <h2>Table</h2>
    <.table id="demo-table" rows={@sample_rows}>
      <:col :let={row} label="Name">{row.name}</:col>
      <:col :let={row} label="Email">{row.email}</:col>
      <:col :let={row} label="Role">{row.role}</:col>
      <:action :let={_row}>
        <.button class="small outline">Edit</.button>
      </:action>
    </.table>

    <h2>List</h2>
    <.list>
      <:item title="Name">Alice Johnson</:item>
      <:item title="Email">alice@example.com</:item>
      <:item title="Role">Admin</:item>
      <:item title="Status">Active</:item>
    </.list>

    <h2>Icon</h2>
    <p class="text-light">Oat does not include an icon library — use inline SVGs directly.</p>
    <div class="hstack">
      <svg
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
      >
        <circle cx="12" cy="12" r="10" />
        <polygon points="10 8 16 12 10 16 10 8" />
      </svg>
      <svg
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
      >
        <polyline points="20 6 9 17 4 12" />
      </svg>
      <svg
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
      >
        <path d="M21 12a9 9 0 1 1-6.219-8.56" />
      </svg>
      <svg
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
      >
        <circle cx="12" cy="12" r="10" /><line x1="12" y1="8" x2="12" y2="12" /><line
          x1="12"
          y1="16"
          x2="12.01"
          y2="16"
        />
      </svg>
    </div>

    <h2>Input with error</h2>
    <.input
      type="text"
      name="demo-err"
      value="wrong"
      errors={["Invalid value", "Must be unique"]}
      label="Error demo"
    />

    <h2>Theme Toggle</h2>
    <.oat_theme_toggle />

    <h2>Locale Selector</h2>
    <.locale_selector locale={@locale} />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Core Components Gallery")
    |> assign(:locale, Gettext.get_locale(OatFirstWeb.Gettext))
    |> assign(:sample_rows, @sample_rows)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("flash-info", _params, socket) do
    {:noreply, put_flash(socket, :info, "This is an info flash message")}
  end

  @impl true
  def handle_event("flash-error", _params, socket) do
    {:noreply, put_flash(socket, :error, "This is an error flash message")}
  end
end
