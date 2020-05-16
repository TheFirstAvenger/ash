defmodule Ash.Filter.Rules do
  # @rules [:subset]

  def subset(
        engine,
        {:attribute_equals, {name, value}},
        {:attribute_equals, {name, value}}
      ) do
    :seresye.assert(engine, {:attribute_equals, {name, value}})
  end

  # def subset(
  #       engine,
  #       {:attribute_equals, {name, _}},
  #       {:attribute_equals, {name, _}}
  #     ) do
  #   :seresye.assert(engine, {:attribute_equals, {name, value}})
  # end

  def subset(
        engine,
        {:filter, {ands, ors, not_filter, attributes, relationships}},
        {:attribute_equals, {:name, "Zach"}}
      ) do
    # :seresye.assert(engine, :attribute_equals {:filter, })
  end


  def start() do
    :seresye.start(:rules)
    :seresye.add_rules(:rules, __MODULE__)

    :seresye.assert(:rules, [
      {:filter, {ands, ors, not_filter, attributes, relationships}},
      {:candidate_filter, {candidate_ands, candidate_ors, candidate_not, candidate_attributes, candidate_relationships}}
    ])

    :seresye.query_kb(:rules, )
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
