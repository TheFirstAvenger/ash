defmodule Ash.Dsl.Definition.UpdateAction do
  use Ash.Dsl.Definition.Bootstrap.Resource
  import Ash.Dsl.Definition.Bootstrap.Resource, only: [attr: 3, attr: 2]

  @name :update_actions
  @identifier :update_action

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:type, :atom, allow_nil?: false, default: {:constant, :update}, writable?: false),
    attr(:primary?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:rules, :term),
    attr(:resource_id, :uuid)
  ]

  @upgrade_fields [:name]
  @builder_name :update
end
