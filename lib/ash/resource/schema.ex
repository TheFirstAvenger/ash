defmodule Ash.Schema do
  @moduledoc """
  Defines an ecto schema for a resource.

  This defines struct representation of a resource. Data layers can rely on this
  schema for persistence.
  """

  defmacro define_schema2(dsl_record) do
    quote bind_quoted: [dsl_record: dsl_record], location: :keep do
      use Ecto.Schema
      @primary_key false

      {:ok, %{results: attributes}} =
        Ash.Dsl.StructureApi.read(Ash.Dsl.Attribute, filter: [resource_id: dsl_record.id])

      {:ok, %{results: belongs_to}} =
        Ash.Dsl.StructureApi.read(Ash.Dsl.BelongsTo,
          filter: [resource_id: dsl_record.id]
        )

      {:ok, %{results: has_one}} =
        Ash.Dsl.StructureApi.read(Ash.Dsl.HasOne,
          filter: [resource_id: dsl_record.id]
        )

      {:ok, %{results: has_many}} =
        Ash.Dsl.StructureApi.read(Ash.Dsl.HasMany,
          filter: [resource_id: dsl_record.id]
        )

      {:ok, %{results: many_to_many}} =
        Ash.Dsl.StructureApi.read(Ash.Dsl.ManyToMany,
          filter: [resource_id: dsl_record.id]
        )

      schema to_string(dsl_record.name) do
        for attribute <- attributes do
          read_after_writes? = attribute.generated? and is_nil(attribute.default)

          field(attribute.name, Ash.Type.ecto_type(attribute.type),
            primary_key: attribute.primary_key?,
            read_after_writes: read_after_writes?
          )
        end

        for relationship <- belongs_to do
          belongs_to(relationship.name, relationship.destination,
            define_field: false,
            foreign_key: relationship.source_field,
            references: relationship.destination_field
          )
        end

        for relationship <- has_one do
          has_one(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- has_many do
          has_many(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- many_to_many do
          many_to_many(relationship.name, relationship.destination,
            join_through: relationship.through,
            join_keys: [
              {relationship.source_field_on_join_table, relationship.source_field},
              {relationship.destination_field_on_join_table, relationship.destination_field}
            ]
          )
        end
      end
    end
  end

  defmacro define_schema(name) do
    quote location: :keep do
      use Ecto.Schema
      @primary_key false

      schema unquote(name) do
        for attribute <- @attributes do
          read_after_writes? = attribute.generated? and is_nil(attribute.default)

          field(attribute.name, Ash.Type.ecto_type(attribute.type),
            primary_key: attribute.primary_key?,
            read_after_writes: read_after_writes?
          )
        end

        for relationship <- Enum.filter(@relationships || [], &(&1.type == :belongs_to)) do
          belongs_to(relationship.name, relationship.destination,
            define_field: false,
            foreign_key: relationship.source_field,
            references: relationship.destination_field
          )
        end

        for relationship <- Enum.filter(@relationships || [], &(&1.type == :has_one)) do
          has_one(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- Enum.filter(@relationships || [], &(&1.type == :has_many)) do
          has_many(relationship.name, relationship.destination,
            foreign_key: relationship.destination_field,
            references: relationship.source_field
          )
        end

        for relationship <- Enum.filter(@relationships || [], &(&1.type == :many_to_many)) do
          many_to_many(relationship.name, relationship.destination,
            join_through: relationship.through,
            join_keys: [
              {relationship.source_field_on_join_table, relationship.source_field},
              {relationship.destination_field_on_join_table, relationship.destination_field}
            ]
          )
        end
      end
    end
  end
end
