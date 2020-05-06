defmodule Ash.Structure.Api do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3, has_many: 2]

  @identifier :api
  @name :apis
  @attributes [
    attr(:interface?, :boolean,
      allow_nil?: false,
      default: {:constant, false}
    ),
    attr(:max_page_size, :integer, allow_nil?: false, default: {:constant, 100}),
    attr(:default_page_size, :integer, allow_nil?: false, default: {:constant, 25})
  ]

  @relationships [
    has_many(:resource, Ash.Structure.ResourceReference)
  ]

  @groups [
    resources: [group: :resources, name: :resource]
  ]

  use Ash.Structure.Bootstrap.Resource
end
