defmodule Ash.Dsl.StructureApi do
  use Ash.Api,
    # TODO: Add the ability to disable page sizes
    max_page_size: 1000,
    default_page_size: 1000

  resources [
    Ash.Dsl.Attribute,
    Ash.Dsl.Resource,
    Ash.Dsl.ResourceReference,
    Ash.Dsl.Api,
    Ash.Dsl.HasMany,
    Ash.Dsl.BelongsTo,
    Ash.Dsl.HasOne,
    Ash.Dsl.ManyToMany,
    Ash.Dsl.CreateAction,
    Ash.Dsl.ReadAction,
    Ash.Dsl.UpdateAction,
    Ash.Dsl.DestroyAction
  ]
end
