defmodule Ash.Filter.Relatives do
    def mother(engine, {:female, x}, {:parent, x, y}) do
      :seresye_engine.assert(engine, {:mother, x, y})
    end

    def father(engine, {:male, x}, {:parent, x, y}) do
      :seresye_engine.assert(engine, {:father, x, y})
    end

    def sister(engine, {:parent, x, y}, {:parent, x, z}, {:female, z}) when y != z do
      :seresye_engine.assert(engine, {:sister, z, y})
    end

    def brother(engine, {:parent, x, y}, {:parent, x, z}, {:male, z}) when y != z do
    :seresye_engine.assert(engine, {:brother, z, y})
  end

  def grandfather(engine, {:father, x, y}, {:parent, y, z}) do
    :seresye_engine.assert(engine, {:grandfather, x, z})
  end

  def grandmother(engine, {:mother, x, y}, {:parent, y, z}) do
    :seresye_engine.assert(engine, {:grandmother, x, z})
  end

  def rules() do
    :functions
    |> __MODULE__.__info__()
    |> Enum.filter(&(elem(&1, 1) > 1))
    |> Enum.map(fn {key, _arity} -> {__MODULE__, key} end)
  end

  def start() do
    :seresye.start(:relatives)
    :seresye.add_rules(:relatives, rules())

    :seresye.assert(:relatives,
                 [{:male, :bob},
                  {:male, :corrado},
                  {:male, :mark},
                  {:male, :caesar},
                  {:female, :alice},
                  {:female, :sara},
                  {:female, :jane},
                  {:female, :anna},
                  {:parent, :jane, :bob},
                  {:parent, :corrado, :bob},
                  {:parent, :jane, :mark},
                  {:parent, :corrado, :mark},
                  {:parent, :jane, :alice},
                  {:parent, :corrado, :alice},
                  {:parent, :bob, :caesar},
                  {:parent, :bob, :anna},
                  {:parent, :sara, :casear},
                  {:parent, :sara, :anna}]
          )
  end
end
