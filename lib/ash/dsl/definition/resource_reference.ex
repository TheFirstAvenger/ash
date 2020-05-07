defmodule Ash.Dsl.Definition.ResourceReference do
  use Ash.Dsl.Definition.Bootstrap.Resource
  import Ash.Dsl.Definition.Bootstrap.Resource, only: [attr: 3, attr: 2]

  @name :resource_references
  @identifier :resource_reference
  @attributes [
    attr(:resource, :atom, allow_nil?: false),
    attr(:short_name, :atom),
    attr(:api_id, :uuid)
  ]

  @upgrade_fields [:resource]

  @builder_name :resource
end
