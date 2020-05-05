# defmodule Ash.ResourceCopy do
#   @doc false
#   def define_resource_module_attributes(mod, opts) do
#     Module.register_attribute(mod, :before_compile_hooks, accumulate: true)
#     Module.register_attribute(mod, :actions, accumulate: true)
#     Module.register_attribute(mod, :relationships, accumulate: true)
#     Module.register_attribute(mod, :mix_ins, accumulate: true)

#     Module.put_attribute(mod, :data_layer, nil)
#   end

#   @doc false
#   def mark_primaries(all_actions) do
#     actions =
#       all_actions
#       |> Enum.group_by(& &1.type)
#       |> Enum.flat_map(fn {type, actions} ->
#         case actions do
#           [action] ->
#             [%{action | primary?: true}]

#           actions ->
#             case Enum.count(actions, & &1.primary?) do
#               0 ->
#                 [{:error, {:no_primary, type}}]

#               1 ->
#                 actions

#               _ ->
#                 [{:error, {:duplicate_primaries, type}}]
#             end
#         end
#       end)

#     Enum.find(actions, fn action -> match?({:error, _}, action) end) || {:ok, actions}
#   end
# end
