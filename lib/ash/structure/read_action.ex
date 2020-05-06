defmodule Ash.Structure.ReadAction do
  import Ash.Structure.Bootstrap.Resource, only: [attr: 3]

  @name :read_actions
  @identifier :read_action

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:type, :atom, allow_nil?: false, default: {:constant, :read}, writable?: false),
    attr(:primary?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:paginate?, :boolean, allow_nil?: false, default: {:constant, true}),
    attr(:rules, :term),
    attr(:resource_id, :uuid)
  ]

  @upgrade_fields [:name]

  use Ash.Structure.Bootstrap.Resource
end
