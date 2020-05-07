defmodule Ash.Dsl.Builder do
  defmacro build_dsl(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      Ash.Dsl.Builder.do_build_dsl(dsl_resource)
    end
  end

  defmacro do_build_dsl(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
      require Ash.Dsl.Builder
      Ash.Dsl.Builder.build_attributes(dsl_resource)

      attributes = @attributes

      Ash.Dsl.Definition.StructureApi.create!(dsl_resource, attributes: Enum.into(attributes, %{}))

      Module.delete_attribute(__MODULE__, :attributes)

      Ash.Dsl.Builder.build_relationships(dsl_resource)
    end
  end

  defmacro build_attributes(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      for attribute <- dsl_resource.attributes() do
        unless attribute.name in dsl_resource.upgrade_fields do
          defmacro unquote(attribute.name)(value) do
            attribute_name = unquote(attribute.name)

            quote location: :keep, bind_quoted: [attribute_name: attribute_name, value: value] do
              @attributes {attribute_name, value}
            end
          end
        end
      end
    end
  end

  def validate_relationships(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      for relationship <- dsl_resource.relationships do
        unless relationship.type == :has_many do
          # TODO: do this with the resource
          raise "Only has_many relationships are supported by the DSL Builder"
        end
      end
    end
  end

  defmacro group_relationships(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      Enum.group_by(dsl_resource.relationships, fn relationship ->
        Enum.find_value(dsl_resource.groups, fn {group, relationship_names} ->
          if Enum.any?(relationship_names, &(&1 == relationship.name)) do
            group
          end
        end) || relationship.name
      end)
    end
  end

  defmacro relationship_modules(relationships) do
    quote location: :keep, bind_quoted: [relationships: relationships] do
      Enum.map(relationships, fn relationship ->
        module_name = Module.concat(relationship.destination, DynamicDsl)

        {:module, mod, _, _} =
          defmodule module_name do
            macro_name =
              case relationship.destination.builder_name() do
                nil -> relationship.destination.identifier()
                name -> name
              end

            case relationship.destination.upgrade_fields() do
              [] ->
                defmacro unquote(macro_name)(opts \\ []) do
                  relationship = unquote(Macro.escape(relationship))

                  quote location: :keep do
                    require Ash.Dsl.Builder
                    Ash.Dsl.Builder.do_build_dsl(unquote(relationship).destination)
                    unquote(opts[:do])
                  end
                end

              upgrade_fields ->
                upgrade_fields = Enum.map(upgrade_fields, &Macro.var(&1, __MODULE__))

                defmacro unquote(macro_name)(unquote_splicing(upgrade_fields), opts \\ []) do
                  module_name = unquote(module_name)
                  upgrade_fields = unquote(upgrade_fields)
                  relationship = unquote(Macro.escape(relationship))

                  quote location: :keep do
                    for {key, value} <- unquote(Keyword.delete(opts, :do)) do
                      @attributes {key, value}
                    end

                    for key <- unquote(upgrade_fields) do
                      @attributes {key, Macro.var(key, __MODULE__)}
                    end

                    require Ash.Dsl.Builder
                    Ash.Dsl.Builder.build_dsl(unquote(relationship.destination))
                  end
                end
            end
          end

        mod
      end)
    end
  end

  defmacro build_relationships(dsl_resource) do
    quote location: :keep, bind_quoted: [dsl_resource: dsl_resource] do
      Ash.Dsl.Builder.validate_relationships(dsl_resource)

      grouped_relationships = Ash.Dsl.Builder.group_relationships(dsl_resource)

      for {group, relationships} <- grouped_relationships do
        modules = Ash.Dsl.Builder.relationship_modules(relationships)

        defmacro unquote(group)(do: body) do
          module_imports =
            for module <- unquote(modules) do
              quote location: :keep do
                import unquote(module)
              end
            end

          module_imports ++
            [
              quote location: :keep do
                unquote(body)
              end
            ]
        end
      end
    end
  end
end
