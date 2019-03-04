defmodule FuzzyCastTest.Post do
  @moduledoc false
  use Ecto.Schema
  alias FuzzyCastTest.User

  schema "posts" do
    field(:title, :string)
    field(:body, :string)
    belongs_to(:user, User)
  end
end
