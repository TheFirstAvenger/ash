defmodule Ash.Subscription do
  defstruct [
    :query,
    :actor,
    :verbose?,
    :action,
    :authorize?,
    :message,
    :results,
    :side_load_path,
    filter_path: []
  ]

  @type t :: %__MODULE__{
          query: Ash.query(),
          message: atom,
          actor: Ash.actor() | nil,
          verbose?: boolean | nil,
          action: atom | nil,
          authorize?: boolean | nil
        }

  @type reconciliation :: :refetch

  @spec reconcile(t(), list(Ash.record()), reconciliation) ::
          {:ok, list(Ash.record())} | {:error, any}
  def reconcile(subscription, _, :refetch) do
    subscription.query.api.read(subscription.query,
      actor: subscription.actor,
      verbose?: subscription.verbose? || false,
      action: subscription.action,
      authorize?: subscription.authorize? || false
    )
  end

  def reconcile(subscription, results, {:create, [], record}) do
    {:ok, add_record(results, record, subscription.query)}
  end

  def reconcile(subscription, results, {:create, path, record}) do
    query = side_load_query(subscription.query, path)

    {:ok,
     update_side_loaded_record(results, path, subscription.query.resource, record, query, :add)}
  end

  def reconcile(subscription, results, {:destroy, [], record}) do
    {:ok, remove_record(results, record, subscription.query.resource)}
  end

  def reconcile(subscription, results, {:destroy, path, record}) do
    query = side_load_query(subscription.query, path)
    {:ok, update_side_loaded_records(results, path, subscription.query, record, query, :remove)}
  end

  defp side_load_query(query, []), do: query

  defp side_load_query(query, [key | rest]) do
    case query.side_load[key] do
      %Ash.Query{} ->
        side_load_query(query, rest)

      other ->
        query.api
        |> Ash.Query.new(Ash.related(query.resource, key))
        |> Ash.Query.side_load(other)
        |> side_load_query(rest)
    end
  end

  defp add_side_loaded_record(results, [last_relationship], resource, record, query, type) do
    relationship = Ash.relationship(resource, last_relationship)

    if relationship.cardinality == :many_to_many do
      destination_value = Map.get(record, relationship.destination_field)

      if destination_value do
        Enum.map(results, fn result ->
          join_records = List.wrap(Map.get(record, relationship.join_relationship))

          related? =
            Enum.any?(join_records, fn join_record ->
              Map.get(join_record, relationship.destination_field_on_join_table) ==
                destination_value
            end)

          if related? do
            query =
              Ash.Query.filter(query,
                in:
                  Enum.map(
                    join_records,
                    &Map.get(&1, relationship.destination_field_on_join_table)
                  )
              )

            case type do
              :add ->
                Map.update!(result, last_relationship, &add_record(&1, record, query))

              :remove ->
                Map.update!(result, last_relationship, &remove_record(&1, record, query))
            end
          else
            result
          end
        end)
      else
        results
      end
    else
      Enum.map(results, fn result ->
        if Map.get(record, relationship.destination_field) ==
             Map.get(result, relationship.source_field) do
          query =
            Ash.Query.filter(query, [
              {relationship.destination_field, Map.get(result, relationship.source_field)}
            ])

          case type do
            :add ->
              Map.update!(result, last_relationship, &add_record(&1, record, query))

            :remove ->
              Map.update!(result, last_relationship, &remove_record(&1, record, query))
          end
        else
          result
        end
      end)
    end
  end

  defp update_side_loaded_record(results, [key | rest], resource, record, query, type) do
    relationship = Ash.relationship(resource, key)

    if relationship.cardinality == :many_to_many do
      destination_value = Map.get(record, relationship.destination_field)

      if destination_value do
        Enum.map(results, fn result ->
          join_records = List.wrap(Map.get(record, relationship.join_relationship))

          related? =
            Enum.any?(join_records, fn join_record ->
              Map.get(join_record, relationship.destination_field_on_join_table) ==
                destination_value
            end)

          if related? do
            Map.update!(
              result,
              key,
              &update_side_loaded_record(
                &1,
                rest,
                relationship.destination,
                record,
                query,
                type
              )
            )
          else
            result
          end
        end)
      else
        results
      end
    else
      Enum.map(results, fn result ->
        Map.update!(
          result,
          key,
          &update_side_loaded_record(&1, rest, relationship.destination, record, query, type)
        )
      end)
    end
  end

  def record_contained(subscription, record, dirty_fields \\ []) do
    Ash.Filter.Runtime.matches?(
      subscription.query.api,
      record,
      subscription.query.filter,
      dirty_fields
    )
  end

  defp remove_record(to_replace, _record, _query) when not is_list(to_replace), do: nil

  defp remove_record(records, record, query) do
  end

  defp add_record(to_replace, record, _query) when not is_list(to_replace) do
    record
  end

  defp add_record(records, record, query) do
    # This is only currently safe to do for side loads because we know
    cond do
      ((query.offset && query.offset != 0) || query.limit) && is_nil(query.sort) ->
        query.api.read!(query)

      query.offset && query.offset != 0 && sorts_before_first?(records, record, query) ->
        query
        |> Ash.Query.limit(1)
        |> query.api.read!()
        |> case do
          [] -> raise "Error while reconciling"
          [record] -> [record | records]
        end

      query.limit && Enum.count(records) == query.limit &&
          sorts_after_last?(records, record, query) ->
        records

      true ->
        Ash.Actions.Sort.runtime_sort([record | records], query.sort)
    end
  end

  defp sorts_before_first?([], _, _), do: false

  defp sorts_before_first?(records, record, %{sort: sort}) do
    [hd(records), record]
    |> Ash.Actions.Sort.runtime_sort(sort)
    |> hd()
    |> Kernel.!=(record)
  end

  defp sorts_after_last?([], _, _), do: false

  defp sorts_after_last?(records, record, %{sort: sort}) do
    [List.last(records), record]
    |> Ash.Actions.Sort.runtime_sort(sort)
    |> hd()
    |> Kernel.!=(record)
  end
end
