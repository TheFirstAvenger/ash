defmodule Ash.Dsl.Definition.CreateAction do
  use Ash.Dsl.Definition.Bootstrap.Resource
  import Ash.Dsl.Definition.Bootstrap.Resource, only: [attr: 3, attr: 2]

  @name :create_actions
  @identifier :create_action

  @attributes [
    attr(:name, :atom, allow_nil?: false),
    attr(:type, :atom, allow_nil?: false, default: {:constant, :create}, writable?: false),
    attr(:primary?, :boolean, allow_nil?: false, default: {:constant, false}),
    attr(:rules, :term),
    attr(:resource_id, :uuid)
  ]

  @name [:name]
  @builder_name :create
end
