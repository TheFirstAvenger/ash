defmodule Ash.Structure.Builder do
  @top_level_dsl ~S"""
  <% import Ash.Structure.Builder %>
  defmodule <%= inspect mod_name %> do
    <%= build_dsl(resource, add_imports(state, [mod_name])) %>
  end

  <%= if import? do %>
    import <%= inspect mod_name %>
  <% end %>
  """

  @resource_dsl ~S"""
  <% import Ash.Structure.Builder %>
  <%= for attribute <- Ash.attributes(resource) do %>
    <%= if attribute.writable? do %>
      # _dsl_builder_resource.eex: building resource attribute
      defmacro <%= attribute.name %>(value) do
        quote bind_quoted: [value: value], location: :keep do
          @attributes {:<%= attribute.name %>, value}
        end
      end
      <% end %>
  <% end %>

  <% groups = if :erlang.function_exported(resource, :groups, 0), do: resource.groups(), else: [] %>

  <%
  grouped_relationships =
    resource
    |> Ash.relationships()
    |> Enum.reject(&(&1.destination == source))
    |> Enum.group_by(&(groups[&1.name][:group]))
   %>

  <%= for {group, relationships} <- grouped_relationships do %>
    <%= build_relationship_group(relationships, group, groups, resource, state) %>
  <% end %>
  """

  @relationship_one_dsl ~S"""
  <% import Ash.Structure.Builder %>
  defmodule <%= inspect mod_name %> do
    # _dsl_builder_one.eex: building relationship destination
    <%= build_dsl(relationship.destination, add_imports(state, [mod_name]), relationship.source) %>
  end

  <%= if upgrade_fields == [] do %>
    defmacro <%= builder_name %>(opts__ \\ []) do
  <% else %>
    defmacro <%= builder_name %>(<%= Enum.join(upgrade_fields, ", ") %>, opts__ \\ []) do
  <% end %>
  # _dsl_builder_one.eex: building relationship section
  quote location: :keep do
    old_value = Module.get_attribute(__MODULE__, :attributes) || []
    Module.delete_attribute(__MODULE__, :attributes)
    Module.register_attribute(__MODULE__, :attributes, accumulate: true)

    import <%= inspect mod_name %>
    <%= for module <- state.imports do %>
      import <%= module %>, only: []
    <% end %>
    unquote(opts__[:do])
    <%= for module <- state.imports do %>
      import <%= module %>
    <% end %>
    import <%= inspect mod_name %>, only: []

    attributes = Enum.into(@attributes, %{})
    <%= for upgrade_field <- upgrade_fields do %>
      attributes = Map.put(attributes, :<%= upgrade_field %>, unquote(<%= upgrade_field %>))
    <% end %>

    attributes =
      Enum.reduce(unquote(Keyword.delete(opts__, :do)), attributes, fn {name, value}, attributes ->
        Map.put(attributes, name, value)
      end)

    for {name, value} <- unquote(Keyword.delete(opts__, :do)) do
      attributes = Map.put(attributes, name, value)
    end

    attributes = Map.put(attributes, :<%= relationship.destination_field %>, @resource_id)

    {:ok, _} = <%= inspect api %>.create(Elixir.<%= inspect relationship.destination %>, attributes: attributes)

    Module.delete_attribute(__MODULE__, :attributes)
    Module.register_attribute(__MODULE__, :attributes, accumulate: true)
    for value <- old_value, do: @attributes value
  end
  """

  @relationship_many_dsl ~S"""
  <% import Ash.Structure.Builder %>
  defmodule <%= nested_mod_name %> do
    # _dsl_builder_many.eex: building relationship destination
    <%= build_dsl(relationship.destination, add_imports(state, [mod_name, nested_mod_name]), relationship.source) %>
  end

  defmodule <%= inspect mod_name %> do
    # _dsl_builder_many.eex: building relationship section
    <%= if upgrade_fields == [] do %>
      defmacro <%= builder_name %>(opts__ \\ []) do
    <% else %>
      defmacro <%= builder_name %>(<%= Enum.join(upgrade_fields, ", ") %>, opts__ \\ []) do
    <% end %>
      quote location: :keep do
        old_value = Module.get_attribute(__MODULE__, :attributes) || []
        Module.delete_attribute(__MODULE__, :attributes)
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)

        <%= for module <- state.imports do %>
          import <%= module %>, only: []
        <% end %>
        import <%= nested_mod_name %>
        unquote(opts__[:do])
        import <%= nested_mod_name %>, only: []
        <%= for module <- state.imports do %>
          import <%= module %>
        <% end %>

        attributes = Enum.into(@attributes, %{})
        <%= for upgrade_field <- upgrade_fields do %>
          attributes = Map.put(attributes, :<%= upgrade_field %>, unquote(<%= upgrade_field %>))
        <% end %>

        attributes =
          Enum.reduce(unquote(Keyword.delete(opts__, :do)), attributes, fn {name, value}, attributes ->
            Map.put(attributes, name, value)
          end)

        for {name, value} <- unquote(Keyword.delete(opts__, :do)) do
          attributes = Map.put(attributes, name, value)
        end

        attributes = Map.put(attributes, :<%= relationship.destination_field %>, @resource_id)

        {:ok, _} = <%= inspect api %>.create(Elixir.<%= inspect relationship.destination %>, attributes: attributes)

        Module.delete_attribute(__MODULE__, :attributes)
        Module.register_attribute(__MODULE__, :attributes, accumulate: true)
        for value <- old_value, do: @attributes value
      end
    end
  end
  """

  @group_dsl ~S"""
  <% import Ash.Structure.Builder %>

  <%= for relationship <- relationships do %>
    <% builder_name = groups[relationship.name][:name] || relationship.destination.type() %>
    <%=  build_relationship_dsl(relationship, mod_name, builder_name, state) %>
  <% end %>

  <% nested_mod_names = Enum.map(relationships, &Module.concat(mod_name, Macro.camelize(Atom.to_string(&1.name)))) %>

  defmacro <%= group_name %>(do: body) do
  # _dsl_builder_group.eex: building group
  quote location: :keep do
      <%= for mod_name <- nested_mod_names do %>
        import <%= inspect mod_name %>
      <% end %>
      <%= for module <- state.imports do %>
        import <%= module %>, only: []
      <% end %>

      unquote(body)
      <%= for module <- state.imports do %>
        import <%= module %>
      <% end %>

      <%= for mod_name <- nested_mod_names do %>
        import <%= inspect mod_name %>, only: []
      <% end %>
    end
  end
  """

  @default_state %{
    current_path: [],
    imports: []
  }

  defmacro build(resource, mod_name, api) do
    quote do
      unquote(resource)
      |> Ash.Structure.Builder.build_resource(unquote(api), unquote(mod_name), true)
      |> Code.eval_string([], __ENV__)
    end
  end

  def build_resource(api, resource, mod_name, import? \\ false) do
    EEx.eval_string(
      @top_level_dsl,
      mod_name: mod_name,
      resource: resource,
      state: @default_state,
      import?: import?,
      api: api
    )
    |> Code.format_string!()
  end

  def build_relationship_group(api, relationships, nil, _groups, mod_prefix, state) do
    to_many_data =
      relationships
      |> Enum.filter(&(&1.cardinality == :many))
      |> Enum.map_join(
        "\n",
        &build_relationship_group(
          api,
          [&1],
          &1.name(),
          [],
          mod_prefix,
          state
        )
      )

    to_one_data =
      relationships
      |> Enum.filter(&(&1.cardinality == :one))
      |> Enum.map_join("\n", &build_relationship_dsl(api, &1, mod_prefix, &1.name, state))

    to_many_data <> "\n" <> to_one_data
  end

  def build_relationship_group(api, relationships, group_name, groups, mod_prefix, state) do
    # mod_name = Module.concat(mod_prefix, Macro.camelize(to_string(group_name)))

    EEx.eval_string(@group_dsl,
      api: api,
      relationships: relationships,
      groups: groups,
      group_name: group_name,
      mod_name: mod_prefix,
      state: state
    )
  end

  def build_relationship_dsl(
        api,
        %{cardinality: :one} = relationship,
        mod_prefix,
        builder_name,
        state
      ) do
    mod_name = Module.concat(mod_prefix, Macro.camelize(Atom.to_string(relationship.name)))

    upgrade_fields =
      case Code.ensure_compiled(relationship.destination) do
        {:module, _module} ->
          if :erlang.function_exported(relationship.destination, :upgrade_fields, 0) do
            relationship.destination.upgrade_fields()
          else
            []
          end

        _ ->
          []
      end

    EEx.eval_string(@relationship_one_dsl,
      api: api,
      upgrade_fields: upgrade_fields,
      relationship: relationship,
      mod_name: mod_name,
      state: state,
      builder_name: builder_name
    )
  end

  def build_relationship_dsl(
        api,
        %{cardinality: :many} = relationship,
        mod_prefix,
        builder_name,
        state
      ) do
    mod_name = Module.concat(mod_prefix, Macro.camelize(Atom.to_string(relationship.name)))

    # This line is ensuring that the destination is compiled, so no need to ensure_compiled
    nested_mod_name = Module.concat(mod_name, Macro.camelize(Ash.type(relationship.destination)))

    upgrade_fields =
      if :erlang.function_exported(relationship.destination, :upgrade_fields, 0) do
        relationship.destination.upgrade_fields()
      else
        []
      end

    EEx.eval_string(
      @relationship_many_dsl,
      api: api,
      relationship: relationship,
      mod_name: mod_name,
      nested_mod_name: nested_mod_name,
      upgrade_fields: upgrade_fields,
      builder_name: builder_name,
      state: state
    )
  end

  def build_dsl(api, resource, state, source \\ nil) do
    EEx.eval_string(@resource_dsl, api: api, resource: resource, state: state, source: source)
  end

  def add_imports(state, imports) do
    %{state | imports: state.imports ++ imports}
  end
end
