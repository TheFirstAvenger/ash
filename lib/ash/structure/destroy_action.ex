defmodule Ash.Structure.DestroyAction do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3, attr: 2]

  @name :destroy_actions
  @identifier :destroy_action

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:type, :atom, allow_nil?: false, default: {:constant, :destroy}, writable?: false),
    attr(:primary?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:rules, :term),
    attr(:resource_id, :uuid)
  ]

  @upgrade_fields [:name]

  use Ash.Structure.Bootstrap.Resource
end
