defmodule Triominos.Repo do
  use Ecto.Repo,
    otp_app: :triominos,
    adapter: Ecto.Adapters.Postgres
end
