defmodule Ash.Dsl.StructureApi do
  use Ash.Api,
    # TODO: Add the ability to disable page sizes
    max_page_size: 1000,
    default_page_size: 1000

  resources [
    Ash.Dsl.Api,
    Ash.Dsl.Attribute,
    Ash.Dsl.BelongsTo,
    Ash.Dsl.CreateAction,
    Ash.Dsl.DataLayerReference,
    Ash.Dsl.DestroyAction,
    Ash.Dsl.HasMany,
    Ash.Dsl.HasOne,
    Ash.Dsl.ManyToMany,
    Ash.Dsl.ReadAction,
    Ash.Dsl.Resource,
    Ash.Dsl.ResourceReference,
    Ash.Dsl.UpdateAction
  ]
end
