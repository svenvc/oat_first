defmodule OatFirst do
  @moduledoc """
  OatFirst keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_countries() do
    path = Application.app_dir(:oat_first, Path.join(["priv", "data", "countries.csv"]))
    data = path |> File.stream!() |> CSV.decode!() |> Enum.to_list()
    fields = hd(data)
    records = tl(data)

    records
    |> Enum.map(fn values ->
      Enum.zip_with(fields, values, fn k, v -> {k, v} end)
      |> Map.new()
    end)
  end
end
