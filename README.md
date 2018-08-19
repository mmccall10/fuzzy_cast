# FuzzyCast
**Warning: work in progress**

`FuzzyCast` is a module for composing introspective %like% queries for `Ecto.Schema` fields.

**Long Way**
```elixir
from(u in User,
      where: ilike(u.email, ^"%gmail%"),
      or_where: ilike(u.email, ^"%yahoo%"),
      or_where: ilike(u.email, ^"%bob%"),
      ...
```

**The FuzzyCast Way**
```elixir
FuzzyCast.compose(User, ~w(gmail yahoo bob))
```

`FuzzyCast` will cast the search values with the schema fields.

#### Example
```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  ...
  
  schema "users" do
    field(:email, :string)
    field(:username, :string)
    field(:password, :string)
    field(:confirmed, :boolean, default: false)
    field(:password_confirmation, :string, virtual: true)
    timestamps()
  end
  ...
end

iex> FuzzyCast.compose(User, 1)
#Ecto.Query<from u in MyApp.Accounts.User, where: u.id == ^1,
 or_where: ilike(u.email, ^"%1%"), or_where: ilike(u.username, ^"%1%"),
 or_where: u.confirmed == ^true>
```
Notice password fields were not returned, `FuzzyCast` will ignore fields that contain "password".

If the search value cannot be cast using `Ecto.Type.cast` it will be ignored. 

#### Example
```elixir
iex> FuzzyCast.compose(User, "gmail")
#Ecto.Query<from u in MyApp.Accounts.User, where: ilike(u.email, ^"%gmail%"),
 or_where: ilike(u.username, ^"%gmail%")>
```
Notice the string "gmail" only matched the type `:string` associted to the field email and username. Fuzzy cast will only search castable fields... hence **FuzzyCast** 

To further demostrate, we can try to get all users with an email containing gmail and who are confirmed.

#### Example
```elixir
iex> FuzzyCast.compose(User, ["gmail", true])
#Ecto.Query<from u in MyApp.Accounts.User, where: ilike(u.email, ^"%gmail%"),
 or_where: ilike(u.username, ^"%gmail%"), or_where: ilike(u.email, ^"%true%"),
 or_where: ilike(u.username, ^"%true%"), or_where: u.confirmed == ^true>

```
Our query looks ok, but it looks like we are also looking for emails that match "%true%". Depending on the use case this might be acceptable, after all it is **fuzzy**. A lot of times we don't need and single results but rather multiple results we pick from. This works best when narrowing or debouncing queries.

`FuzzyCast.compose` simply return and `Ecto.Query`. This means we can it can be composed like any other `Ecto.Query`.

#### Example
```elixir
iex> from(u in User) |> FuzzyCast.compose(~w(gmail yahoo)) |> Repo.all
[
  %MyApp.User{
    email: "bob@gmail.com",
    ...
  }
  ...
]
iex> q = from(u in User, where: u.confirmed == true) |> FuzzyCast.compose(["gmail", "yahoo"])
#Ecto.Query<from u in MyApp.Accounts.User, where: u.confirmed == true,
 or_where: ilike(u.email, ^"%gmail%"), or_where: ilike(u.username, ^"%gmail%"),
 or_where: ilike(u.email, ^"%yahoo%"), or_where: ilike(u.username, ^"%yahoo%")>
iex> Repo.aggregate(q, :count, :id)
500
```

Composing queries with `Ecto.Query` works, but we can also pipe multiple `FuzzyCast.compose` calls. 

We might want to look for a match of "mike" across all fields, and a match for emails that include "gmail" or "yahoo".

```elixir 
FuzzyCast.compose(User, ["gmail", "yahoo"], fields: [:email]) |> FuzzyCast.compose("mike")
#Ecto.Query<from u in MyApp.Accounts.User, where: ilike(u.email, ^"%gmail%"),
 or_where: ilike(u.email, ^"%yahoo%"), or_where: ilike(u.email, ^"%mike%"),
 or_where: ilike(u.username, ^"%mike%")>

```

## Installation

This package can be installed by adding `fuzzy_cast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuzzy_cast, "~> 0.1"}
  ]
end
```

Up to date docs can be found at [https://hexdocs.pm/fuzzy_cast](https://hexdocs.pm/fuzzy_cast).

