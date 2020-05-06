defmodule Ash.Structure.ResourceReference do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3, attr: 2, has_many: 2]

  @name :resource_references
  @identifier :resource_reference
  @attributes [
    attr(:resource, :atom, allow_nil?: false),
    attr(:short_name, :atom),
    attr(:api_id, :uuid)
  ]

  @upgrade_fields [:resource]

  use Ash.Structure.Bootstrap.Resource
end
