defmodule Mix.Tasks.Ash.CompileDsl do
  use Mix.Task

  @resource_destination_path "lib/ash/dsl/syntax/resource.ex"
  @api_destination_path "lib/ash/dsl/syntax/api.ex"

  def run(_) do
    api_contents =
      Ash.Dsl.Api
      |> Ash.Dsl.Builder.build_resource(Ash.Dsl.Syntax.Api)
      |> puts()

    resource_contents =
      Ash.Dsl.Resource
      |> Ash.Dsl.Builder.build_resource(Ash.Dsl.Syntax.Resource)
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
end
