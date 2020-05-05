defmodule Ash.Resource2 do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      require Ash.Dsl.Helpers
      @using_opts opts
      Module.register_attribute(__MODULE__, :extensions, accumulate: true)
      require Ash.Resource2
      @add_before_compile Ash.Resource2
      @process_record Ash.Resource2
      Ash.Dsl.Helpers.prepare(Ash.Dsl.Resource, @using_opts)
      import Ash.Dsl.Syntax.Resource
      @before_compile Ash.Dsl.Helpers
    end
  end

  require Ash.Dsl.Helpers

  Ash.Dsl.Helpers.def_global_accessors(Ash.Dsl.Resource)

  def process_record(%dsl_resource{} = dsl_record) do
    dsl_record
    |> create_belongs_to_fields()
    |> mark_primary_actions()

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

    record
  end

  defp mark_primary_actions(record) do
    for action_resource <- [
          Ash.Dsl.CreateAction,
          Ash.Dsl.UpdateAction,
          Ash.Dsl.DestroyAction,
          Ash.Dsl.ReadAction
        ] do
      case Ash.Dsl.StructureApi.read!(action_resource, filter: [resource_id: record.id]) do
        %{results: []} ->
          :ok

        %{results: [%{primary?: true}]} ->
          :ok

        %{results: [%{primary?: false} = action]} ->
          {:ok, _} = Ash.Dsl.StructureApi.update(action, attributes: %{primary?: true})

        %{results: [first | _] = actions} ->
          case Enum.count(actions, & &1.primary?) do
            0 ->
              raise Ash.Error.ResourceDslError,
                message:
                  "Multiple actions of type #{first.type} defined, one must be designated as `primary?: true`",
                path: [:actions, first.type]

            1 ->
              :ok

            other ->
              raise Ash.Error.ResourceDslError,
                message:
                  "#{other} actions of type #{first.type} configured as `primary?: true`, but only one action per type can be the primary",
                path: [:actions, first.type]
          end
      end

      record
    end
  end

  def before_compile(dsl_record) do
    quote do
      require Ash.Schema
      Ash.Schema.define_schema2(unquote(Macro.escape(dsl_record)))
    end
  end
end
