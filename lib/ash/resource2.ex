defmodule Ash.Resource2 do
  defmacro __using__(opts) do
    quote location: :keep do
      require Ash.Dsl.Helpers
      @using_opts unquote(opts)
      require Ash.Resource2
      @add_before_compile Ash.Resource2
      @process_record Ash.Resource2
      @before_compile Ash.Dsl.Helpers
      Ash.Dsl.Helpers.prepare(Ash.Dsl.Resource, @using_opts)
      import Ash.Dsl.Syntax.Resource
    end
  end

  require Ash.Dsl.Helpers

  Ash.Dsl.Helpers.def_global_accessors(Ash.Dsl.Resource)

  def process_record(%dsl_resource{} = dsl_record) do
    dsl_record
    |> create_belongs_to_fields()

    {:ok, %{results: [record]}} =
      Ash.Dsl.StructureApi.read(dsl_resource, filter: [id: dsl_record.id])

    record
  end

  defp create_belongs_to_fields(record) do
    {:ok, %{results: belongs_to}} =
      Ash.Dsl.StructureApi.read(Ash.Dsl.BelongsTo,
        filter: [resource_id: record.id]
      )

    belongs_to
    |> Enum.filter(& &1.define_field?)
    |> Enum.each(fn relationship ->
      {:ok, _} =
        Ash.Dsl.StructureApi.create(Ash.Dsl.Attribute,
          attributes: %{
            resource_id: record.id,
            name: relationship.source_field,
            type: relationship.field_type
          }
        )
    end)
  end

  def before_compile(dsl_record) do
    quote do
      require Ash.Schema
      Ash.Schema.define_schema2(unquote(Macro.escape(dsl_record)))
    end
  end
end
