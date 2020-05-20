defmodule Ash.Resource.Actions.Create do
  @moduledoc "The representation of a `create` action."
  defstruct [:type, :name, :primary?]

  @type t :: %__MODULE__{
          type: :create,
          name: atom,
          primary?: boolean
        }

  @opt_schema Ashton.schema(
                opts: [
                  primary?: :boolean
                ],
                defaults: [
                  primary?: false
                ],
                describe: [
                  primary?:
                    "Whether or not this action should be used when no action is specified by the caller."
                ]
              )

  @doc false
  def opt_schema(), do: @opt_schema

  @spec new(Ash.resource(), atom, Keyword.t()) :: {:ok, t()} | {:error, term}
  def new(_resource, name, opts \\ []) do
    case Ashton.validate(opts, @opt_schema) do
      {:ok, opts} ->
        {:ok,
         %__MODULE__{
           name: name,
           type: :create,
           primary?: opts[:primary?]
         }}

      {:error, error} ->
        {:error, error}
    end
  end
end
