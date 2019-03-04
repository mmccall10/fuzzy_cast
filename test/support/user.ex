defmodule FuzzyCastTest.User do
  @moduledoc false
  use Ecto.Schema
  alias FuzzyCastTest.Post

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:hashed_password, :string)
    field(:age, :integer)
    has_many(:posts, Post)
  end
end
