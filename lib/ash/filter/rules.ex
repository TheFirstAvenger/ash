defmodule Ash.Filter.Rules do
  @rules [:subset]

  def subset(
        engine,
        {:actual_attribute_is, attribute, x},
        {:filter_attribute_equals, attribute, x}
      ) do
    :seresye.assert(engine, {:filter_subset, attribute})
  end

  def start() do
    :seresye.start(:rules)
    :seresye.add_rules(:rules, __MODULE__)

    :seresye.assert(:rules, [
      {:actual_attribute_is, :name, "zach"},
      {:filter_attribute_equals, :name, "zach"}
    ])
  end

  # start () ->
  #   application:start(seresye) % Only if it is not already started
  #   seresye:start(relatives),
  #   seresye:add_rules(relatives, ?MODULE)

  #   seresye:assert(relatives,
  #                  [{male, bob}, {male, corrado}, {male, mark}, {male, caesar},
  #                   {female, alice}, {female, sara}, {female, jane}, {female, anna},
  #                   {parent, jane, bob}, {parent, corrado, bob},
  #                   {parent, jane, mark}, {parent, corrado, mark},
  #                   {parent, jane, alice}, {parent, corrado, alice},
  #                   {parent, bob, caesar}, {parent, bob, anna},
  #                   {parent, sara, casear}, {parent, sara, anna}]),
  #   ok.
end
