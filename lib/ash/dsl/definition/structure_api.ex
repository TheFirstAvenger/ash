defmodule Ash.Dsl.Definition.StructureApi do
  use Ash.Api.Interface

  def groups do
    [
      resources: [group: :resources, name: :resource]
    ]
  end

  def interface?(), do: true

  def max_page_size(), do: 1000
  def default_page_size(), do: 1000

  def ash_page_size(), do: 1000
  def ash_default_page_size(), do: 1000

  def resources do
    [
      %{resource: Ash.Dsl.Definition.ResourceReference},
      %{resource: Ash.Dsl.Definition.Api},
      %{resource: Ash.Dsl.Definition.Attribute},
      %{resource: Ash.Dsl.Definition.BelongsTo},
      %{resource: Ash.Dsl.Definition.CreateAction},
      %{resource: Ash.Dsl.Definition.DataLayerReference},
      %{resource: Ash.Dsl.Definition.DestroyAction},
      %{resource: Ash.Dsl.Definition.HasMany},
      %{resource: Ash.Dsl.Definition.HasOne},
      %{resource: Ash.Dsl.Definition.ManyToMany},
      %{resource: Ash.Dsl.Definition.ReadAction},
      %{resource: Ash.Dsl.Definition.Resource},
      %{resource: Ash.Dsl.Definition.UpdateAction}
    ]
    |> Enum.map(&Map.put(&1, :short_name, nil))
  end
end
