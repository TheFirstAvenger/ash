defmodule Ash.Dsl.CreateAction do
  use Ash.Resource,
    type: "create_action",
    name: "create_actions"

  use Ash.DataLayer.Ets

  attributes do
    attribute :name, :atom, allow_nil?: false
    attribute :type, :atom, allow_nil?: false, default: {:constant, :create}, writable?: false
    attribute :primary?, :boolean, allow_nil?: false, default: {:constant, false}
    # # TODO: Figure out how to represent this in the builder!
    attribute :rules, :term
    attribute :resource_id, :uuid
  end

  actions do
    create :default
    read :default
  end

  def upgrade_fields() do
    [:name]
  end
end
