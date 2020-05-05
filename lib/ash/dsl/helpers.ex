defmodule Ash.Dsl.Helpers do
  defmacro __before_compile__(_env) do
    quote bind_quoted: [], location: :keep do
      attrs =
        @attributes
        |> Kernel.||([])
        |> Enum.into(%{})
        |> Map.put(:id, @resource_id)

      attrs =
        Enum.reduce(@using_opts, attrs, fn {key, value}, attrs ->
          Map.put(attrs, key, value)
        end)

      {:ok, record} = Ash.Dsl.StructureApi.create(@dsl_resource, attributes: attrs)

      record =
        case Module.get_attribute(__MODULE__, :process_record) do
          nil ->
            record

          process_record ->
            process_record.process_record(record)
        end

      case Module.get_attribute(__MODULE__, :add_before_compile) do
        nil ->
          :ok

        module ->
          Code.eval_quoted(module.before_compile(record), [], __ENV__)
      end

      Ash.Dsl.Helpers.def_accessors(record)
    end
  end

  defmacro def_global_accessors(dsl_resource) do
    quote bind_quoted: [dsl_resource: dsl_resource], location: :keep do
      for attribute <- Ash.attributes(dsl_resource) -- [:id] do
        attribute_name = :"ash_#{attribute.name}"

        def unquote(attribute.name)(resource) do
          apply(resource, unquote(attribute_name), [])
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
          attribute_name = :"ash_#{group}"

          def unquote(group)(resource, search \\ []) do
            apply(resource, unquote(attribute_name), [search])
          end
        end)
      end

      ungrouped_relationships =
        Enum.reject(Ash.relationships(dsl_resource), &Keyword.has_key?(groups, &1.name))

      for relationship <- ungrouped_relationships do
        attribute_name = :"ash_#{relationship.name}"

        if relationship.cardinality == :one do
          def unquote(relationship.name)(resource) do
            apply(resource, unquote(attribute_name), [])
          end
        else
          def unquote(relationship.name)(resource, search \\ []) do
            apply(resource, unquote(attribute_name), [search])
          end
        end
      end
    end
  end

  defmacro def_accessors(record) do
    quote bind_quoted: [record: record], location: :keep do
      for attribute <- Ash.attributes(@dsl_resource) -- [:id] do
        attribute_name = :"ash_#{attribute.name}"
        value = Map.get(record, attribute.name)

        def unquote(attribute_name)() do
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
                relationship = Ash.relationship(@dsl_resource, relationship_name)

                {:ok, %{results: results}} =
                  Ash.Dsl.StructureApi.read(relationship.destination,
                    filter: [{relationship.destination_field, @resource_id}]
                  )

                results
              end)

            {group_name, all_records}
          end)

        for {group_name, results} <- groups_to_results do
          def unquote(:"ash_#{group_name}")(search \\ []) do
            if search == [] do
              unquote(Macro.escape(results))
            else
              Enum.filter(unquote(Macro.escape(results)), fn related ->
                Enum.all?(search, fn {key, value} ->
                  Map.fetch(related, key) == {:ok, value}
                end)
              end)
            end
          end
        end
      end

      ungrouped_relationships =
        Enum.reject(Ash.relationships(@dsl_resource), &Keyword.has_key?(groups, &1.name))

      for relationship <- ungrouped_relationships do
        attribute_name = :"ash_#{relationship.name}"

        {:ok, %{results: related}} =
          Ash.Dsl.StructureApi.read(relationship.destination,
            filter: [{relationship.destination_field, @resource_id}]
          )

        if relationship.cardinality == :one do
          def unquote(attribute_name)() do
            unquote(Macro.escape(List.first(related)))
          end
        else
          def unquote(attribute_name)(search \\ []) do
            if search == [] do
              unquote(Macro.escape(related))
            else
              Enum.filter(unquote(Macro.escape(related)), fn related ->
                Enum.all?(search, fn {key, value} ->
                  Map.fetch(related, key) == {:ok, value}
                end)
              end)
            end
          end
        end
      end
    end
  end

  defmacro prepare(dsl_resource, _opts) do
    quote bind_quoted: [dsl_resource: dsl_resource],
          location: :keep do
      @dsl_resource dsl_resource
      @resource_id Ecto.UUID.generate()

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
    end
  end
end
