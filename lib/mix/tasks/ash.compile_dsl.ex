defmodule Mix.Tasks.Ash.CompileDsl do
  use Mix.Task

  @resource_destination_path "lib/ash/dsl/syntax/resource.ex"
  @api_destination_path "lib/ash/dsl/syntax/api.ex"
  @dsl_template_path "lib/templates/resource_dsl.ex.eex"

  @default_state %{
    current_path: [],
    imports: []
  }

  def run(_) do
    api_contents =
      @dsl_template_path
      |> Path.expand()
      |> EEx.eval_file(
        mod_name: Ash.Dsl.Syntax.Api,
        resource: Ash.Dsl.Api,
        state: @default_state
      )
      |> Code.format_string!()
      |> puts()

    resource_contents =
      @dsl_template_path
      |> Path.expand()
      |> EEx.eval_file(
        mod_name: Ash.Dsl.Syntax.Resource,
        resource: Ash.Dsl.Resource,
        state: @default_state
      )
      |> Code.format_string!()
      |> puts()

    @api_destination_path
    |> Path.expand()
    |> File.write!(api_contents)

    @resource_destination_path
    |> Path.expand()
    |> File.write!(resource_contents)
  end

  defp puts(item) do
    IO.puts(item)
    item
  end

  @dsl_builder_one_template_path "lib/templates/_dsl_builder_one.eex"
  @dsl_builder_many_template_path "lib/templates/_dsl_builder_many.eex"
  @dsl_builder_group_template_path "lib/templates/_dsl_builder_group.eex"

  def build_relationship_group(relationships, nil, _groups, mod_prefix, state) do
    to_many_data =
      relationships
      |> Enum.filter(&(&1.cardinality == :many))
      |> Enum.map_join(
        "\n",
        &build_relationship_group(
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
      |> Enum.map_join("\n", &build_relationship_dsl(&1, mod_prefix, &1.name, state))

    to_many_data <> "\n" <> to_one_data
  end

  def build_relationship_group(relationships, group_name, groups, mod_prefix, state) do
    # mod_name = Module.concat(mod_prefix, Macro.camelize(to_string(group_name)))

    @dsl_builder_group_template_path
    |> Path.expand()
    |> EEx.eval_file(
      relationships: relationships,
      groups: groups,
      group_name: group_name,
      mod_name: mod_prefix,
      state: state
    )
  end

  def build_relationship_dsl(%{cardinality: :one} = relationship, mod_prefix, builder_name, state) do
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

    @dsl_builder_one_template_path
    |> Path.expand()
    |> EEx.eval_file(
      upgrade_fields: upgrade_fields,
      relationship: relationship,
      mod_name: mod_name,
      state: state,
      builder_name: builder_name
    )
  end

  def build_relationship_dsl(
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

    @dsl_builder_many_template_path
    |> Path.expand()
    |> EEx.eval_file(
      relationship: relationship,
      mod_name: mod_name,
      nested_mod_name: nested_mod_name,
      upgrade_fields: upgrade_fields,
      builder_name: builder_name,
      state: state
    )
  end

  @resource_template_path "lib/templates/_dsl_builder_resource.eex"

  def build_dsl(resource, state, source \\ nil) do
    @resource_template_path
    |> Path.expand()
    |> EEx.eval_file(resource: resource, state: state, source: source)
  end

  def add_imports(state, imports) do
    %{state | imports: state.imports ++ imports}
  end
end
