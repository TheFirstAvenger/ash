defmodule Ash.Dsl.ReadAction do
  use Ash.Resource,
    type: "read_action",
    name: "read_actions"

  use Ash.DataLayer.Ets

  attributes do
    attribute :name, :atom, allow_nil?: false
    attribute :type, :atom, allow_nil?: false, default: {:constant, :read}, writable?: false
    attribute :primary?, :boolean, allow_nil?: false, default: {:constant, false}
    attribute :paginate?, :boolean, allow_nil?: false, default: {:constant, true}
    # TODO: Support array types
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
