defmodule Ash.Structure.StructureApi do
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
      %Ash.Structure.ResourceReference{resource: Ash.Structure.ResourceReference},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.Api},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.Attribute},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.BelongsTo},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.CreateAction},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.DataLayerReference},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.DestroyAction},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.HasMany},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.HasOne},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.ManyToMany},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.ReadAction},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.Resource},
      %Ash.Structure.ResourceReference{resource: Ash.Structure.UpdateAction}
    ]
  end
end
