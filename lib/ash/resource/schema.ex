defmodule Ash.Schema do
  @moduledoc false

  # Defines an ecto schema for a resource.

  # This defines struct representation of a resource. Data layers can rely on this
  # schema for persistence.

  defmacro define_schema do
    quote unquote: false do
      alias Ash.Query.Aggregate
      use Ecto.Schema
      @primary_key false

      schema Ash.DataLayer.source(__MODULE__) do
        for attribute <- Ash.Resource.attributes(__MODULE__) do
          read_after_writes? = attribute.generated? and is_nil(attribute.default)

          field(attribute.name, Ash.Type.ecto_type(attribute.type),
            primary_key: attribute.primary_key?,
            read_after_writes: read_after_writes?
          )
        end

        field(:aggregates, :map, virtual: true, default: %{})

        for aggregate <- Ash.Resource.aggregates(__MODULE__) do
          {:ok, type} = Aggregate.kind_to_type(aggregate.kind)

          field(aggregate.name, Ash.Type.ecto_type(type), virtual: true)
        end

        relationships = Ash.Resource.relationships(__MODULE__)

        for relationship <- Enum.filter(relationships, &(&1.type == :belongs_to)) do
          belongs_to(relationship.name, relationship.destination,
            define_field: false,
            foreign_key: relationship.source_field,
            references: relationship.destination_field
          )
        end

        for relationship <- Enum.filter(relationships, &(&1.type == :has_one)) do
          has_one(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- Enum.filter(relationships, &(&1.type == :has_many)) do
          has_many(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- Enum.filter(relationships, &(&1.type == :many_to_many)) do
          many_to_many(relationship.name, relationship.destination,
            join_through: relationship.through,
            join_keys: [
              {relationship.source_field_on_join_table, relationship.source_field},
              {relationship.destination_field_on_join_table, relationship.destination_field}
            ]
          )
        end

        for relationship <- relationships do
          new_struct_fields =
            Enum.reject(@struct_fields, fn {name, _} -> name == relationship.name end) ++
              [{relationship.name, %Ash.NotLoaded{field: relationship.name, type: :relationship}}]

          Module.delete_attribute(__MODULE__, :struct_fields)

          Module.register_attribute(__MODULE__, :struct_fields, accumulate: true)

          Enum.each(
            Enum.reverse(new_struct_fields),
            &Module.put_attribute(__MODULE__, :struct_fields, &1)
          )
        end
      end
    end
  end
end
