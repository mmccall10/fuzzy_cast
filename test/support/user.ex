defmodule FuzzyCastTest.User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:hashed_password, :string)
    field(:age, :integer)
  end
end
