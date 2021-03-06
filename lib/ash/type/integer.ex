defmodule Ash.Type.Integer do
  @constraints [
    max: [
      type: {:custom, __MODULE__, :integer, []},
      doc: "Enforces a maximum on the value"
    ],
    min: [
      type: {:custom, __MODULE__, :integer, []},
      doc: "Enforces a minimum on the value"
    ]
  ]
  @moduledoc """
  Represents a simple integer

  A builtin type that can be referenced via `:integer`

  ### Constraints

  #{NimbleOptions.docs(@constraints)}
  """
  use Ash.Type

  @impl true
  def storage_type, do: :integer

  @impl true
  def constraints, do: @constraints

  @doc false
  def integer(value) when is_integer(value), do: {:ok, value}
  def integer(_), do: {:error, "must be an integer"}

  def apply_constraints(nil, _), do: :ok

  def apply_constraints(value, constraints) do
    errors =
      Enum.reduce(constraints, [], fn
        {:max, max}, errors ->
          if value > max do
            ["must be less than `#{max}`" | errors]
          else
            errors
          end

        {:min, min}, errors ->
          if value < min do
            ["must be more than `#{min}`" | errors]
          else
            errors
          end
      end)

    case errors do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  @impl true
  def cast_input(value) do
    Ecto.Type.cast(:integer, value)
  end

  @impl true
  def cast_stored(value) do
    Ecto.Type.load(:integer, value)
  end

  @impl true
  def dump_to_native(value) do
    Ecto.Type.dump(:integer, value)
  end
end
