defmodule FuzzyCastTest do
  use ExUnit.Case
  doctest FuzzyCast

  import Ecto.Query, warn: false

  alias FuzzyCastTest.User

  test "compose/2 with Schema and params add generates query with ilikes where clauses for all castable fields" do
    query = FuzzyCast.compose(User, ~w(mike))

    assert %Ecto.Query{
             wheres: [
               %Ecto.Query.BooleanExpr{
                 expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :name]}, [], []}, {:^, [], [0]}]},
                 op: :and,
                 params: [{"%mike%", :string}]
               },
               %Ecto.Query.BooleanExpr{
                 expr: {:ilike, [], [{{:., [], [{:&, [], [0]}, :email]}, [], []}, {:^, [], [0]}]},
                 op: :or,
                 params: [{"%mike%", :string}]
               }
             ]
           } = query
  end
end
