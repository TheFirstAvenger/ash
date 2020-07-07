defmodule Ash.Subscription.Monitor do
  defstruct [:subscriptions]

  use GenServer

  def broadcast_event(api, resource, event) do
    name = Module.concat([api, resource, Monitor])

    GenServer.cast(name, {:event, event})
  end

  def subscribe(subscription) do
    do_subscribe(subscription)
    :ok
  end

  defp do_subscribe(subscription) do
    subscription = %{subscription | side_load_path: subscription.side_load_path || []}
    name = Module.concat([subscription.query.api, subscription.query.resource, Monitor])

    GenServer.cast(name, {:subscribe, self(), subscription})

    subscribe_to_side_loads(subscription)
    subscribe_to_filters(subscription)
    :ok
  end

  defp subscribe_to_side_loads(subscription) do
    subscription.query.side_load
    |> Kernel.||([])
    |> Enum.each(fn
      {key, %Ash.Query{} = query} ->
        do_subscribe(%{
          subscription
          | query: query,
            side_load_path: subscription.side_load_path ++ [key]
        })

      {key, further} ->
        related = Ash.related(subscription.query.resource, key)
        query = Ash.Query.side_load(subscription.query.api.query(related), further)

        do_subscribe(%{
          subscription
          | query: query,
            side_load_path: subscription.side_load_path ++ [key]
        })
    end)
  end

  defp subscribe_to_filters(subscription) do
    subscription.query.filter
    |> Ash.Filter.relationship_paths()
    |> Kernel.++([[]])
    |> Enum.reject(&(&1 == subscription.filter_path))
    |> Enum.each(fn relationship_path ->
      filter =
        Ash.Filter.filter_expression_by_relationship_path(
          subscription.query.filter,
          relationship_path,
          true
        )

      new_resource = Ash.related(subscription.query.resource, relationship_path)

      do_subscribe(%{
        subscription
        | query: %{subscription.query | filter: filter, resource: new_resource},
          filter_path: relationship_path
      })
    end)
  end

  @spec start_link(nil | maybe_improper_list | map) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts,
      name: Module.concat([opts[:api], opts[:resource], Monitor])
    )
  end

  @impl true
  def init(_opts) do
    {:ok, %__MODULE__{subscriptions: %{}}}
  end

  @impl true
  def handle_cast({:subscribe, pid, subscription}, state) do
    _ = Process.monitor(pid)

    {:noreply, %{state | subscriptions: Map.put(state.subscriptions, pid, subscription)}}
  end

  @impl true
  def handle_cast({:event, {:destroy, record}}, state) do
    Enum.each(state.subscriptions, fn {pid, subscription} ->
      case Ash.Subscription.record_contained(subscription, record) do
        false ->
          :ok

        true ->
          case subscription do
            %{filter_path: [], side_load_path: side_load_path} ->
              send(pid, {subscription.message, {:destroy, side_load_path, record}})

            subscription ->
              send(pid, {subscription.message, :refetch})
          end

        :unknown ->
          send(pid, {subscription.message, :refetch})
      end
    end)

    {:noreply, state}
  end

  def handle_cast({:event, {:create, record}}, state) do
    Enum.each(state.subscriptions, fn {pid, subscription} ->
      case Ash.Subscription.record_contained(subscription, record) do
        false ->
          :ok

        true ->
          case subscription do
            %{filter_path: [], side_load_path: side_load_path} ->
              send(pid, {subscription.message, {:create, side_load_path, record}})

            subscription ->
              send(pid, {subscription.message, :refetch})
          end

        :unknown ->
          send(pid, {subscription.message, :refetch})
      end
    end)

    {:noreply, state}
  end

  def handle_cast({:event, {:upsert, changeset, record}}, state) do
    dirty_fields = Map.keys(changeset.changes)

    Enum.each(state.subscriptions, fn {pid, subscription} ->
      case Ash.Subscription.record_contained(subscription, record, dirty_fields) do
        false ->
          :ok

        true ->
          case subscription do
            %{filter_path: [], side_load_path: side_load_path} ->
              send(pid, {subscription.message, {:upsert, side_load_path, record}})

            subscription ->
              send(pid, {subscription.message, :refetch})
          end
      end
    end)
  end

  def handle_cast({:event, _}, state) do
    Enum.each(state.subscriptions, fn {pid, subscription} ->
      send(pid, {subscription.message, :refetch})
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {:noreply, %{state | subscriptions: Map.delete(state.subscriptions, pid)}}
  end

  def handle_info({:EXIT, pid, _}, state) do
    {:noreply, %{state | subscriptions: Map.delete(state.subscriptions, pid)}}
  end
end
