defmodule Ash.Dsl.Syntax.Resource do
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
  defmacro description(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:description, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro identifier(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:identifier, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro name(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:name, value}
    end
  end

  # _dsl_builder_resource.eex: building resource attribute
  defmacro id(value) do
    quote bind_quoted: [value: value], location: :keep do
      @attributes {:id, value}
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.DestroyActions.DestroyAction do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro primary?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:primary?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.DestroyActions do
    # _dsl_builder_many.eex: building relationship section
    defmacro destroy(name, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.DestroyActions.DestroyAction
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.DestroyActions.DestroyAction, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.DestroyAction, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.UpdateActions.UpdateAction do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro primary?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:primary?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.UpdateActions do
    # _dsl_builder_many.eex: building relationship section
    defmacro update(name, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.UpdateActions.UpdateAction
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.UpdateActions.UpdateAction, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.UpdateAction, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.ReadActions.ReadAction do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro paginate?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:paginate?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro primary?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:primary?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.ReadActions do
    # _dsl_builder_many.eex: building relationship section
    defmacro read(name, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.ReadActions.ReadAction
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.ReadActions.ReadAction, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.ReadAction, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.CreateActions.CreateAction do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro primary?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:primary?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.CreateActions do
    # _dsl_builder_many.eex: building relationship section
    defmacro create(name, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.CreateActions.CreateAction
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.CreateActions.CreateAction, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.CreateAction, attributes: attributes)
      end
    end
  end

  defmacro actions(do: body) do
    # _dsl_builder_group.eex: building group
    quote location: :keep do
      import Ash.Dsl.Resource.DestroyActions

      import Ash.Dsl.Resource.UpdateActions

      import Ash.Dsl.Resource.ReadActions

      import Ash.Dsl.Resource.CreateActions

      import Elixir.Ash.Dsl.Syntax.Resource, only: []

      unquote(body)

      import Elixir.Ash.Dsl.Syntax.Resource

      import Ash.Dsl.Resource.DestroyActions, only: []

      import Ash.Dsl.Resource.UpdateActions, only: []

      import Ash.Dsl.Resource.ReadActions, only: []

      import Ash.Dsl.Resource.CreateActions, only: []
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.Attributes.Attribute do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro write_rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:write_rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro description(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:description, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro update_default(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:update_default, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro default(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:default, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro writable?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:writable?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro primary_key?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:primary_key?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro allow_nil?(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:allow_nil?, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro type(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:type, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.Attributes do
    # _dsl_builder_many.eex: building relationship section
    defmacro attribute(name, type, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.Attributes.Attribute
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.Attributes.Attribute, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes = Map.put(attributes, :type, unquote(type))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.Attribute, attributes: attributes)
      end
    end
  end

  defmacro attributes(do: body) do
    # _dsl_builder_group.eex: building group
    quote location: :keep do
      import Ash.Dsl.Resource.Attributes

      import Elixir.Ash.Dsl.Syntax.Resource, only: []

      unquote(body)

      import Elixir.Ash.Dsl.Syntax.Resource

      import Ash.Dsl.Resource.Attributes, only: []
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.ManyToManyRelationships.ManyToMany do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro write_rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:write_rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination_field_on_join_table(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination_field_on_join_table, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro source_field_on_join_table(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:source_field_on_join_table, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro through(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:through, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro reverse_relationship(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:reverse_relationship, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro source_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:source_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro field_type(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:field_type, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.ManyToManyRelationships do
    # _dsl_builder_many.eex: building relationship section
    defmacro many_to_many(name, destination, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.ManyToManyRelationships.ManyToMany
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.ManyToManyRelationships.ManyToMany, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes = Map.put(attributes, :destination, unquote(destination))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.ManyToMany, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.BelongsToRelationships.BelongsTo do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro write_rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:write_rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro reverse_relationship(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:reverse_relationship, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro source_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:source_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro field_type(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:field_type, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.BelongsToRelationships do
    # _dsl_builder_many.eex: building relationship section
    defmacro belongs_to(name, destination, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.BelongsToRelationships.BelongsTo
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.BelongsToRelationships.BelongsTo, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes = Map.put(attributes, :destination, unquote(destination))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.BelongsTo, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.HasOneRelationships.HasOne do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro write_rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:write_rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro reverse_relationship(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:reverse_relationship, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro source_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:source_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro field_type(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:field_type, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.HasOneRelationships do
    # _dsl_builder_many.eex: building relationship section
    defmacro has_one(name, destination, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.HasOneRelationships.HasOne
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.HasOneRelationships.HasOne, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes = Map.put(attributes, :destination, unquote(destination))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.HasOne, attributes: attributes)
      end
    end
  end

  defmodule Elixir.Ash.Dsl.Resource.HasManyRelationships.HasMany do
    # _dsl_builder_many.eex: building relationship destination

    # _dsl_builder_resource.eex: building resource attribute
    defmacro resource_id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:resource_id, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro write_rules(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:write_rules, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro reverse_relationship(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:reverse_relationship, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro source_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:source_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination_field(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination_field, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro field_type(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:field_type, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro destination(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:destination, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro name(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:name, value}
      end
    end

    # _dsl_builder_resource.eex: building resource attribute
    defmacro id(value) do
      quote bind_quoted: [value: value], location: :keep do
        @attributes {:id, value}
      end
    end
  end

  defmodule Ash.Dsl.Resource.HasManyRelationships do
    # _dsl_builder_many.eex: building relationship section
    defmacro has_many(name, destination, opts \\ []) do
      quote location: :keep do
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        import Elixir.Ash.Dsl.Syntax.Resource, only: []

        import Elixir.Ash.Dsl.Resource.HasManyRelationships.HasMany
        unquote(opts[:do])
        import Elixir.Ash.Dsl.Resource.HasManyRelationships.HasMany, only: []

        import Elixir.Ash.Dsl.Syntax.Resource

        attributes = Enum.into(@attributes, %{})

        attributes = Map.put(attributes, :name, unquote(name))

        attributes = Map.put(attributes, :destination, unquote(destination))

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts, :do)), attributes, fn {name, value},
                                                                         attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :resource_id, @resource_id)

        {:ok, _} =
          Elixir.Ash.Dsl.StructureApi.create(Elixir.Ash.Dsl.HasMany, attributes: attributes)
      end
    end
  end

  defmacro relationships(do: body) do
    # _dsl_builder_group.eex: building group
    quote location: :keep do
      import Ash.Dsl.Resource.ManyToManyRelationships

      import Ash.Dsl.Resource.BelongsToRelationships

      import Ash.Dsl.Resource.HasOneRelationships

      import Ash.Dsl.Resource.HasManyRelationships

      import Elixir.Ash.Dsl.Syntax.Resource, only: []

      unquote(body)

      import Elixir.Ash.Dsl.Syntax.Resource

      import Ash.Dsl.Resource.ManyToManyRelationships, only: []

      import Ash.Dsl.Resource.BelongsToRelationships, only: []

      import Ash.Dsl.Resource.HasOneRelationships, only: []

      import Ash.Dsl.Resource.HasManyRelationships, only: []
    end
  end
end