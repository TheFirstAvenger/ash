defmodule Ash.Dsl.Definition.Interface do
  defmacro def_global_accessors(dsl_resource) do
    quote bind_quoted: [dsl_resource: dsl_resource], location: :keep do
      for attribute <- dsl_resource.attributes() -- [:id] do
        def unquote(attribute.name)(resource) do
          apply(resource, unquote(attribute.name), [])
        end
      end

      groups =
        if :erlang.function_exported(dsl_resource, :groups, 0) do
          dsl_resource.groups()
        else
          []
        end

      if groups != [] do
        groups
        |> Enum.map(fn {_, config} ->
          config[:group]
        end)
        |> Enum.uniq()
        |> Enum.each(fn group ->
          def unquote(group)(resource) do
            apply(resource, unquote(group))
          end
        end)
      end

      ungrouped_relationships =
        Enum.reject(dsl_resource.ash_relationships(), &Keyword.has_key?(groups, &1.name))

      for relationship <- ungrouped_relationships do
        def unquote(relationship.name)(resource) do
          apply(resource, unquote(relationship.name), [])
        end
      end
    end
  end

  defmacro def_accessors(record) do
    quote bind_quoted: [record: record], location: :keep do
      for attribute <- @dsl_resource.attributes() -- [:id] do
        value = Map.get(record, attribute.name)

        def unquote(attribute.name)() do
          unquote(value)
        end
      end

      groups =
        if :erlang.function_exported(@dsl_resource, :groups, 0) do
          @dsl_resource.groups()
        else
          []
        end

      if groups != [] do
        groups_to_results =
          groups
          |> Enum.reduce(%{}, fn {relationship, config}, acc ->
            Map.update(acc, config[:group], [relationship], &[relationship | &1])
          end)
          |> Enum.map(fn {group_name, relationship_names} ->
            all_records =
              Enum.flat_map(relationship_names, fn relationship_name ->
                relationship = @dsl_resource.ash_relationships([name: relationship_name], :find)

                {:ok, %{results: results}} =
                  @dsl_api.read(relationship.destination,
                    filter: [{relationship.destination_field, @resource_id}]
                  )

                results
              end)

            {group_name, all_records}
          end)

        for {group_name, results} <- groups_to_results do
          def unquote(group_name)() do
            unquote(Macro.escape(results))
          end
        end
      end

      ungrouped_relationships =
        Enum.reject(@dsl_resource.ash_relationships(), &Keyword.has_key?(groups, &1.name))

      for relationship <- ungrouped_relationships do
        {:ok, %{results: related}} =
          @dsl_api.read(relationship.destination,
            filter: [{relationship.destination_field, @resource_id}]
          )

        if relationship.cardinality == :one do
          def unquote(attribute.name)() do
            unquote(Macro.escape(List.first(related)))
          end
        else
          def unquote(attribute.name)() do
            unquote(Macro.escape(related))
          end
        end
      end
    end
  end
end
