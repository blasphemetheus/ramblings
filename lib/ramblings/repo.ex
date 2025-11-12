defmodule Ramblings.Repo do
  use Ecto.Repo,
    otp_app: :ramblings,
    adapter: Ecto.Adapters.Postgres
end
