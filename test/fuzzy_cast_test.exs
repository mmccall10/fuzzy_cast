defmodule FuzzyCastTest do
  use ExUnit.Case
  doctest FuzzyCast

  import Ecto.Query, warn: false

  alias FuzzyCastTest.User
  alias FuzzyCastTest.Post

  test "compose/2 with Schema and params add generates query with ilikes where clauses for all castable fields" do
    query = FuzzyCast.compose(User, ~w(bob))

    assert %Ecto.Query{
             wheres: [
               %Ecto.Query.BooleanExpr{
                 expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :name]}, [], []}, {:^, [], [0]}]},
                 op: :and,
                 params: [{"%bob%", :string}]
               },
               %Ecto.Query.BooleanExpr{
                 expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :email]}, [], []}, {:^, [], [0]}]},
                 op: :or,
                 params: [{"%bob%", :string}]
               }
             ]
           } = query
  end

  test "compose/2 with Ecto.Query add params and generates query with ilike where clauses for all castable fields" do
    query = FuzzyCast.compose(from(u in User, as: :user, join: p in Post, as: :posts), "bob")

    assert [
             %Ecto.Query.BooleanExpr{
               expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :name]}, [], []}, {:^, [], [0]}]},
               op: :and,
               params: [{"%bob%", :string}]
             },
             %Ecto.Query.BooleanExpr{
               expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :email]}, [], []}, {:^, [], [0]}]},
               op: :or,
               params: [{"%bob%", :string}]
             }
           ] = query.wheres
  end

  test "compose/3 with fields option limits query to only specified field(s)" do
    query = FuzzyCast.compose(from(u in User, join: p in Post), "bob", fields: [:email])

    assert [
             %Ecto.Query.BooleanExpr{
               expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :email]}, [], []}, {:^, [], [0]}]},
               op: :and,
               params: [{"%bob%", :string}]
             }
           ] = query.wheres
  end

  test "compose/1 returns %Ecto.Query" do
    query = User |> FuzzyCast.build("mike") |> FuzzyCast.compose()

    assert [
             %Ecto.Query.BooleanExpr{
               expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :name]}, [], []}, {:^, [], [0]}]},
               op: :and,
               params: [{"%bob%", :string}]
             }
           ] = query.wheres
  end

  test "build/2 with returns %FuzzyCast{} with populated data" do
    fuzz =
      FuzzyCast.build(User, "joe") == %FuzzyCast{
        base_query: %Ecto.Query{},
        field_casts: [
          [field: :name, value: "joe", type: :string],
          [field: :email, value: "joe", type: :string]
        ],
        fields: nil,
        schema: FuzzyCastTest.User,
        search_query: %Ecto.Query{},
        terms: ["joe"]
      }
  end

  test "build/3 with fields option returns %FuzzyCast{} with populated data" do
    fuzz =
      FuzzyCast.build(User, "joe", fields: [:email]) == %FuzzyCast{
        base_query: %Ecto.Query{},
        field_casts: [
          [field: :email, value: "joe", type: :string]
        ],
        fields: nil,
        schema: FuzzyCastTest.User,
        search_query: %Ecto.Query{},
        terms: ["joe"]
      }
  end
end
