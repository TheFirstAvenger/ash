defmodule Ash.Dsl.ResourceReference do
  use Ash.Resource,
    name: "resource_references",
    type: "resource_reference"

  use Ash.DataLayer.Ets

  attributes do
    attribute :resource, :atom, allow_nil?: false
    attribute :short_name, :atom
    attribute :api_id, :uuid
  end

  actions do
    create :default
    read :default
    update :default
  end

  def upgrade_fields() do
    [:resource]
  end
end
