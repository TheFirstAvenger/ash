defmodule Ash.Dsl.Syntax.Api do
  # _dsl_builder_resource.eex: building resource attribute
  defmacro default_page_size(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:default_page_size, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro max_page_size(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:max_page_size, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro interface?(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:interface?, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro id(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:id, value}
    end
  end

  defmodule Elixir.Ash.Dsl.Api.Resources.ResourceReference do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro api_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:api_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro short_name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:short_name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Api.Resources do
    # _dsl_builder_many.eex: building relationship section

    defmacro resource(resource, opts__ \\ []) do
      quote location: :keep do
        old_value = Module.get_attribute(__MODULE__, :attributes) || []
        Module.delete_attribute(__MODULE__, :attributes)
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Api, only: []

        import Elixir.Ash.Dsl.Api.Resources.ResourceReference
        unquote(opts__[:do])
        import Elixir.Ash.Dsl.Api.Resources.ResourceReference, only: []

        import Elixir.Ash.Dsl.Syntax.Api

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :resource, unquote(resource))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts__, :do)), attributes, fn {name, value},
                                                                           attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts__, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :api_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.ResourceReference,
            attributes: attributes
          )

        Module.delete_attribute(__MODULE__, :attributes)
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)
        for value <- old_value, do: @attributes(value)
      end
    end
  end

  defmacro resources(do: body) do
    # _dsl_builder_group.eex: building group
    quote location: :keep do
      import Ash.Dsl.Api.Resources

      import Elixir.Ash.Dsl.Syntax.Api, only: []

      unquote(body)

      import Elixir.Ash.Dsl.Syntax.Api

      import Ash.Dsl.Api.Resources, only: []
    end
  end
end