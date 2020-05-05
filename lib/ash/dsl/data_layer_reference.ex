defmodule Ash.Dsl.DataLayerReference do
  use Ash.Resource,
    name: "data_layer_references",
    type: "data_layer_reference"

  use Ash.DataLayer.Ets

  attributes do
    attribute :module, :atom, allow_nil?: false
    # TODO: type for keyword?
    attribute :opts, :term, allow_nil?: false, default: {:constant, []}

    attribute :resource_id, :uuid
  end

  actions do
    create :default
    read :default
    update :default
  end

  def upgrade_fields() do
    [:module, :opts]
  end
end
