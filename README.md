# FuzzyCast
*** Warning: work in progress ***

FuzzyCast is a module to help compose introspective like queries across Ecto schema fields.

FuzzyCast greatly reduces code needed to search across Ecto schema fields.

** Long Way **
```
from(u in User,
      where: ilike(u.email, ^"%gmail%"),
      or_where: ilike(u.email, ^"%yahoo%"),
      or_where: ilike(u.email, ^"%bob%")
```

** The FuzzyCast Way **
```
FuzzyCast.compose(User, ~w(gmail yahoo bob))
```

`FuzzyCast.compose` simply returns an`Ecto.Query` for composition.
```
iex> FuzzyCast.compose(User, ~w(gmail yahoo bob)) |> Repo.all
[
  %MyApp.User{
    email: "bob@gmail.com",
    ...
  }
  ...
]
iex> from(u in User, select: [:id, :email]) |> FuzzyCast.compose("gmail") |> Repo.aggregate(:count, :id)
500
```

Explicitly passing fields to be searched is optional.
For example we migth to search for user who's email migh contain gmail or yahoo
```
FuzzyCast.compose(User, ["gmail", "yahoo"], fields: [:email])
```

FuzzyCast simply returns an `Ecto.Query` but can also accept an `Ecto.Query`.
This means we can pipe mulitple `FuzzyCast` calls.
For example, We might want to look for the match of "m" across all fields, and match for emails that include gmail and yahoo.
```
from(u in User)
|> FuzzyCast.compose(["gmail", "yahoo"], fields: [:email])
|> FuzzyCast.compose("m")
|> Repo.all
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fuzzy_cast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuzzy_cast, git: "https://github.com/pyramind10/fuzzy_cast.git"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fuzzy_cast](https://hexdocs.pm/fuzzy_cast).

