defmodule Ash.Api.Interface do
  @moduledoc false

  defmacro __using__(_) do
    quote location: :keep do
      alias Ash.Api

      @impl true
      def get!(resource, id, params \\ []) do
        Api.get!(__MODULE__, resource, id, params)
      end

      @impl true
      def get(resource, id, params \\ []) do
        case Api.get(__MODULE__, resource, id, params) do
          {:ok, instance} -> {:ok, instance}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def read!(query, opts \\ [])

      # sobelow_skip ["SQL.Query"]
      def read!(resource, opts) when is_atom(resource) do
        read!(query(resource), opts)
      end

      def read!(query, opts) do
        Api.read!(__MODULE__, query, opts)
      end

      @impl true
      def read(query, opts \\ [])

      # sobelow_skip ["SQL.Query"]
      def read(resource, opts) when is_atom(resource) do
        read(query(resource), opts)
      end

      def read(query, opts) do
        case Api.read(__MODULE__, query, opts) do
          {:ok, results} -> {:ok, results}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      # sobelow_skip ["SQL.Query"]
      def subscribe!(resource, opts) when is_atom(resource) do
        subscribe!(query(resource), opts)
      end

      def subscribe!(query, opts) do
        Api.subscribe!(__MODULE__, query, opts)
      end

      @impl true
      def subscribe(query, opts \\ [])

      # sobelow_skip ["SQL.Query"]
      def subscribe(resource, opts) when is_atom(resource) do
        subscribe(query(resource), opts)
      end

      def subscribe(query, opts) do
        case Api.subscribe(__MODULE__, query, opts) do
          {:ok, subscription} -> {:ok, subscription}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def side_load!(data, query, opts \\ []) do
        Api.side_load!(__MODULE__, data, query, opts)
      end

      @impl true
      def side_load(data, query, opts \\ []) do
        case Api.side_load(__MODULE__, data, query, opts) do
          {:ok, results} -> {:ok, results}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def create!(resource, params \\ []) do
        Api.create!(__MODULE__, resource, params)
      end

      @impl true
      def create(resource, params \\ []) do
        case Api.create(__MODULE__, resource, params) do
          {:ok, instance} -> {:ok, instance}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def update!(record, params \\ []) do
        Api.update!(__MODULE__, record, params)
      end

      @impl true
      def update(record, params \\ []) do
        case Api.update(__MODULE__, record, params) do
          {:ok, instance} -> {:ok, instance}
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def destroy!(record, params \\ []) do
        Api.destroy!(__MODULE__, record, params)
      end

      @impl true
      def destroy(record, params \\ []) do
        case Api.destroy(__MODULE__, record, params) do
          :ok -> :ok
          {:error, error} -> {:error, List.wrap(error)}
        end
      end

      @impl true
      def reload!(%resource{} = record, params \\ []) do
        id = record |> Map.take(Ash.primary_key(resource)) |> Enum.to_list()
        get!(resource, id, params)
      end

      @impl true
      def reload(%resource{} = record, params \\ []) do
        id = record |> Map.take(Ash.primary_key(resource)) |> Enum.to_list()
        get(resource, id, params)
      end

      def query(resource) do
        Ash.Query.new(__MODULE__, resource)
      end
    end
  end
end
