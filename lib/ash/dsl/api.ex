defmodule Ash.Dsl.Api do
  use Ash.Resource,
    type: "api",
    name: "apis"

  use Ash.DataLayer.Ets

  attributes do
    attribute :interface?, :boolean, allow_nil?: false, default: {:constant, false}
    attribute :max_page_size, :integer, allow_nil?: false, default: {:constant, 100}
    attribute :default_page_size, :integer, allow_nil?: false, default: {:constant, 25}
  end

  relationships do
    has_many :resources, Ash.Dsl.ResourceReference
  end

  actions do
    create :default
    read :default
  end

  def groups do
    [
      resources: [group: :resources, name: :resource]
    ]
  end
end
