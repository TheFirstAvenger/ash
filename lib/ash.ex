defmodule Ash do
  @moduledoc """
  The primary interface for interrogating apis and resources.

  This is not the code level interface for a resource. Instead, call functions
  on an `Api` module that contains those resources. This is for retrieving
  resource/api configurations.
  """
  alias Ash.Resource.Relationships.{BelongsTo, HasOne, HasMany, ManyToMany}
  alias Ash.Resource.Actions.{Create, Read, Update, Destroy}

  @type record :: struct
  @type relationship_cardinality :: :many | :one
  @type cardinality_one_relationship() :: HasOne.t() | BelongsTo.t()
  @type cardinality_many_relationship() :: HasMany.t() | ManyToMany.t()
  @type relationship :: cardinality_one_relationship() | cardinality_many_relationship()
  @type resource :: module
  @type data_layer :: module
  @type data_layer_query :: struct
  @type api :: module
  @type error :: struct
  @type filter :: map()
  @type params :: Keyword.t()
  @type create_params :: Keyword.t()
  @type update_params :: Keyword.t()
  @type delete_params :: Keyword.t()
  @type sort :: Keyword.t()
  @type side_loads :: Keyword.t()
  @type attribute :: Ash.Attributes.Attribute.t()
  @type action :: Create.t() | Read.t() | Update.t() | Destroy.t()
  @type query :: Ash.Query.t()
  @type actor :: Ash.record()

  defmacro partial_resource(do: body) do
    quote do
      defmacro __using__(_) do
        body = unquote(body)

        quote do
          unquote(body)
        end
      end
    end
  end

  def ash_error?(value) do
    !!Ash.Error.impl_for(value)
  end

  def to_ash_error(values) when is_list(values) do
    values =
      Enum.map(values, fn value ->
        if ash_error?(value) do
          value
        else
          Ash.Error.Unknown.exception(error: values)
        end
      end)

    Ash.Error.choose_error(values)
  end

  def to_ash_error(value) do
    to_ash_error([value])
  end

  def describe(resource) do
    resource.describe()
  end

  def authorizers(resource) do
    resource.authorizers()
  end

  @spec resource_module?(module) :: boolean
  def resource_module?(module) do
    :attributes
    |> module.module_info()
    |> Keyword.get(:behaviour, [])
    |> Enum.any?(&(&1 == Ash.Resource))
  end

  @spec data_layer_can?(resource(), Ash.DataLayer.feature()) :: boolean
  def data_layer_can?(resource, feature) do
    data_layer = data_layer(resource)

    data_layer && data_layer.can?(resource, feature)
  end

  @spec resources(api) :: list(resource())
  def resources(api) do
    api.resources()
  end

  @spec primary_key(resource()) :: list(attribute)
  def primary_key(resource) do
    resource.primary_key()
  end

  @spec relationship(resource(), atom() | String.t()) :: relationship() | nil
  def relationship(resource, relationship_name) when is_bitstring(relationship_name) do
    Enum.find(resource.relationships(), &(to_string(&1.name) == relationship_name))
  end

  def relationship(resource, relationship_name) do
    Enum.find(resource.relationships(), &(&1.name == relationship_name))
  end

  @spec relationships(resource()) :: list(relationship())
  def relationships(resource) do
    resource.relationships()
  end

  def primary_action!(resource, type) do
    case primary_action(resource, type) do
      nil -> raise "Required primary #{type} action for #{inspect(resource)}"
      action -> action
    end
  end

  @spec primary_action(resource(), atom()) :: action() | nil
  def primary_action(resource, type) do
    resource
    |> actions()
    |> Enum.filter(&(&1.type == type))
    |> case do
      [action] -> action
      actions -> Enum.find(actions, & &1.primary?)
    end
  end

  @spec action(resource(), atom(), atom()) :: action() | nil
  def action(resource, name, type) do
    Enum.find(resource.actions(), &(&1.name == name && &1.type == type))
  end

  @spec actions(resource()) :: list(action())
  def actions(resource) do
    resource.actions()
  end

  @spec attribute(resource(), String.t() | atom) :: attribute() | nil
  def attribute(resource, name) when is_bitstring(name) do
    Enum.find(resource.attributes, &(to_string(&1.name) == name))
  end

  def attribute(resource, name) do
    Enum.find(resource.attributes, &(&1.name == name))
  end

  @spec attributes(resource()) :: list(attribute())
  def attributes(resource) do
    resource.attributes()
  end

  @spec name(resource()) :: String.t()
  def name(resource) do
    resource.name()
  end

  @spec type(resource()) :: String.t()
  def type(resource) do
    resource.type()
  end

  @spec data_layer(resource()) :: data_layer()
  def data_layer(resource) do
    resource.data_layer()
  end
end
