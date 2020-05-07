defmodule Ash.Dsl.Test do
  use Ash.Resource

  attributes do
    attribute :foo, :string, allow_nil?: true
  end

  data_layer(Ash.DataLayer.Ets)
end
