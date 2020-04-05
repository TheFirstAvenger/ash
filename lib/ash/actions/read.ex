defmodule Ash.Actions.Read do
  alias Ash.Engine2
  alias Ash.Engine2.Request
  alias Ash.Actions.SideLoad

  def run(api, resource, action, params) do
    transaction_result =
      Ash.DataLayer.transact(resource, fn ->
        do_run(api, resource, action, params)
      end)

    case transaction_result do
      {:ok, value} -> value
      {:error, error} -> {:error, error}
    end
  end

  defp do_run(api, resource, action, params) do
    filter = Keyword.get(params, :filter, [])
    sort = Keyword.get(params, :sort, [])
    side_loads = Keyword.get(params, :side_load, [])
    side_load_filter = Keyword.get(params, :side_load_filter)
    page_params = Keyword.get(params, :page, [])

    filter =
      case filter do
        %Ash.Filter{} -> filter
        filter -> Ash.Filter.parse(resource, filter, api)
      end

    with %Ash.Filter{errors: [], requests: filter_requests} = filter <-
           filter,
         query <- Ash.DataLayer.resource_to_query(resource),
         {:ok, sort} <- Ash.Actions.Sort.process(resource, sort),
         {:ok, sorted_query} <- Ash.DataLayer.sort(query, sort, resource),
         # We parse the query for validation/side_load auth, but don't use it for querying.
         {:ok, _filtered_query} <- Ash.DataLayer.filter(sorted_query, filter, resource),
         {:ok, side_load_requests} <-
           SideLoad.requests(api, resource, side_loads, filter, side_load_filter),
         {:ok, paginator} <-
           Ash.Actions.Paginator.paginate(api, resource, action, sorted_query, page_params),
         %{data: %{root: %{data: data}}, errors: errors} = engine when errors == %{} <-
           do_authorized(
             paginator.query,
             params,
             filter,
             resource,
             api,
             action,
             side_load_requests ++ filter_requests
           ),
         paginator <- %{paginator | results: data} do
      {:ok, SideLoad.attach_side_loads(paginator, engine.data)}
    else
      %{errors: errors} -> {:error, errors}
      %Ash.Filter{errors: errors} -> {:error, errors}
      {:error, error} -> {:error, error}
    end
  end

  defp do_authorized(query, params, filter, resource, api, action, requests) do
    request =
      Request.new(
        resource: resource,
        rules: action.rules,
        filter: filter,
        action_type: action.type,
        data:
          Request.UnresolvedField.data([], Ash.Filter.optional_paths(filter), fn request, data ->
            fetch_filter = Ash.Filter.request_filter_for_fetch(request.filter, data)

            case Ash.DataLayer.filter(query, fetch_filter, resource) do
              {:ok, final_query} ->
                Ash.DataLayer.run_query(final_query, resource)

              {:error, error} ->
                {:error, error}
            end
          end),
        resolve_when_fetch_only?: true,
        path: [:data],
        name: "#{action.type} - `#{action.name}`"
      )

    if params[:authorization] do
      Engine2.run(
        [request | requests],
        api,
        user: params[:authorization][:user],
        log_final_report?: params[:authorization][:log_final_report?] || false
      )
    else
      Engine2.run([request | requests], api, fetch_only?: true)
    end
  end
end
