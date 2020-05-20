defmodule Ash.Resource.Relationships.ManyToMany do
  defstruct [
    :name,
    :type,
    :source,
    :through,
    :cardinality,
    :destination,
    :source_field,
    :destination_field,
    :source_field_on_join_table,
    :destination_field_on_join_table,
    :reverse_relationship
  ]

  @type t :: %__MODULE__{
          type: :many_to_many,
          cardinality: :many,
          source: Ash.resource(),
          name: atom,
          through: Ash.resource(),
          destination: Ash.resource(),
          source_field: atom,
          destination_field: atom,
          source_field_on_join_table: atom,
          destination_field_on_join_table: atom,
          reverse_relationship: atom
        }

  @opt_schema Ashton.schema(
                opts: [
                  source_field_on_join_table: :atom,
                  destination_field_on_join_table: :atom,
                  source_field: :atom,
                  destination_field: :atom,
                  through: :atom,
                  reverse_relationship: :atom
                ],
                defaults: [
                  source_field: :id,
                  destination_field: :id
                ],
                required: [
                  :through
                ],
                describe: [
                  through: "The resource to use as the join table.",
                  reverse_relationship:
                    "A requirement for side loading data. Must be the name of an inverse relationship on the destination resource.",
                  source_field_on_join_table:
                    "The field on the join table that should line up with `source_field` on this resource. Default: [resource_name]_id",
                  destination_field_on_join_table:
                    "The field on the join table that should line up with `destination_field` on the related resource. Default: [relationshihp_name]_id",
                  source_field:
                    "The field on this resource that should line up with `source_field_on_join_table` on the join table.",
                  destination_field:
                    "The field on the related resource that should line up with `destination_field_on_join_table` on the join table."
                ]
              )

  @doc false
  def opt_schema(), do: @opt_schema

  @spec new(
          resource :: Ash.resource(),
          resource_name :: String.t(),
          name :: atom,
          related_resource :: Ash.resource(),
          opts :: Keyword.t()
        ) :: {:ok, t()} | {:error, term}
  def new(resource, resource_name, name, related_resource, opts \\ []) do
    # Don't call functions on the resource! We don't want it to compile here
    case Ashton.validate(opts, @opt_schema) do
      {:ok, opts} ->
        {:ok,
         %__MODULE__{
           name: name,
           type: :many_to_many,
           source: resource,
           cardinality: :many,
           through: opts[:through],
           destination: related_resource,
           reverse_relationship: opts[:reverse_relationship],
           source_field: opts[:source_field],
           destination_field: opts[:destination_field],
           source_field_on_join_table:
             opts[:source_field_on_join_table] || :"#{resource_name}_id",
           destination_field_on_join_table:
             opts[:destination_field_on_join_table] || :"#{name}_id"
         }}

      {:error, errors} ->
        {:error, errors}
    end
  end
end
