defmodule OatFirstWeb.PageController do
  use OatFirstWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
