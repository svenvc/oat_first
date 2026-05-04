defmodule OatFirst.Repo do
  use Ecto.Repo,
    otp_app: :oat_first,
    adapter: Ecto.Adapters.Postgres
end
