defmodule FuzzyCast do
  @moduledoc """

  Compose fuzzy like `Ecto.Query`'s accross `Ecto` schema fields.

  ```
  FuzzyCast.compose(User, ~w(gmail yahoo bob))
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
  """
  import Ecto.Query, warn: false
  alias __MODULE__

  @enforce_keys [:schema, :terms]

  defstruct base_query: nil,
            fields: nil,
            field_casts: [],
            schema: nil,
            search_query: nil,
            terms: []

  @doc """
  `FuzzyCast.compose` returns an`Ecto.Query` for composition.
  ```
  FuzzyCast.compose(User, ~w(gmail yahoo bob)) |> Repo.all

  from(u in User, select: [:id, :email])
  |> FuzzyCast.compose("gmail")
  |> Repo.aggregate(:count, :id)
  500
  ```

  Pass fields to specifcy columns to search
  ```
  FuzzyCast.compose(User, ["gmail", "yahoo"], fields: [:email])
  ```
  """
  def compose(schema_or_query, terms, opts \\ [])

  def compose(%Ecto.Query{} = ecto_q, terms, opts) do
    {_table, schema} = ecto_q.from

    build(schema, terms, opts ++ [base_query: ecto_q])
    |> search_query()
  end

  def compose(schema, terms, opts) do
    build(schema, terms, opts)
    |> search_query()
  end

  def compose(%FuzzyCast{search_query: search_query}) when not is_nil(search_query) do
    search_query
  end

  def compose(%FuzzyCast{search_query: search_query} = fuzzycast) when is_nil(search_query) do
    do_build(fuzzycast) |> search_query
  end

  def build(schema, terms, opts \\ [])

  def build(%Ecto.Query{} = ecto_q, terms, opts) do
    {_table, schema} = ecto_q.from
    build(schema, terms, opts ++ [base_query: ecto_q])
  end

  def build(schema, terms, opts) when is_list(terms) do
    base_fuzzy(schema, terms, opts)
    |> do_build()
  end

  def build(schema, term, opts) do
    build(schema, [term], opts)
  end

  defp base_fuzzy(schema, terms, opts) do
    %FuzzyCast{terms: terms, schema: schema, fields: opts[:fields], base_query: opts[:base_query]}
  end

  defp do_build(%FuzzyCast{} = fuzzycast) do
    fuzzycast
    |> gen_base_query()
    |> query_fields()
    |> build_search_query()
  end

  def search_query(%__MODULE__{} = fuzzycast) do
    fuzzycast.search_query
  end

  defp gen_base_query(%FuzzyCast{schema: schema, base_query: base_query} = fuzzycast) do
    case base_query do
      nil -> %{fuzzycast | base_query: from(x in schema)}
      _ -> fuzzycast
    end
  end

  defp query_fields(%FuzzyCast{terms: terms} = fuzzycast) do
    %{fuzzycast | field_casts: Enum.flat_map(terms, &map_fields_to_term(&1, fuzzycast))}
  end

  defp map_fields_to_term(term, fuzzycast) do
    fuzzycast
    |> map_query_fields(to_string(term))
    |> Enum.reject(&(&1 == :error))
  end

  defp map_query_fields(fuzzycast, search_term) do
    fields =
      case fuzzycast.fields do
        nil -> fuzzycast.schema.__schema__(:fields)
        _ -> fuzzycast.fields
      end

    fields
    |> Enum.filter(&strip_protected/1)
    |> Enum.map(fn field ->
      type = fuzzycast.schema.__schema__(:type, field)

      case type do
        nil ->
          :error

        _ ->
          with {:ok, value} <- Ecto.Type.cast(type, search_term) do
            [field: field, value: value, type: type]
          else
            :error -> :error
          end
      end
    end)
  end

  defp strip_protected(field) do
    unless to_string(field) =~ "password", do: field
  end

  defp build_search_query(%FuzzyCast{base_query: base_query, field_casts: fields} = fuzzycast) do
    query =
      case fields do
        [] ->
          base_query

        _ ->
          [head | tail] = fields
          where_query = compose_where_query(head, base_query)
          Enum.reduce(tail, where_query, &compose_or_where_query(&1, &2))
      end

    %{fuzzycast | search_query: query}
  end

  defp compose_where_query(field_item, query) do
    case field_item[:type] do
      :string ->
        value = "%" <> field_item[:value] <> "%"
        from(q in query, where: ilike(field(q, ^field_item[:field]), ^value))

      _ ->
        from(q in query, where: field(q, ^field_item[:field]) == ^field_item[:value])
    end
  end

  defp compose_or_where_query(field_item, query) do
    case field_item[:type] do
      :string ->
        value = "%" <> field_item[:value] <> "%"
        from(q in query, or_where: ilike(field(q, ^field_item[:field]), ^value))

      _ ->
        from(q in query, or_where: field(q, ^field_item[:field]) == ^field_item[:value])
    end
  end
end
