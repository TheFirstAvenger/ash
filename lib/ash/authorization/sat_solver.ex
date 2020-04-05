defmodule Ash.Authorization.SatSolver do
  alias Ash.Authorization.Clause

  @dialyzer {:no_return, :"picosat_solve/1"}

  def solve(requests, facts, negations, ids) when is_nil(ids) do
    requests
    |> Enum.map(&Map.get(&1, :rules))
    |> build_requirements_expression(facts, nil)
    |> add_negations_and_solve(negations)
  end

  def solve(requests, facts, negations, ids) do
    sets_of_rules = Enum.map(requests, &Map.get(&1, :rules))

    ids
    |> Enum.reduce(nil, fn id, expr ->
      requirements_expression = build_requirements_expression(sets_of_rules, facts, id)

      if expr do
        {:and, expr, requirements_expression}
      else
        requirements_expression
      end
    end)
    |> add_negations_and_solve(negations)
  end

  def solve2(rules_with_filters, facts) do
    expression =
      Enum.reduce(rules_with_filters, nil, fn rules_with_filter, expr ->
        {rules, filter} =
          case rules_with_filter do
            {rules, filter} ->
              {rules, filter}

            rules ->
              {rules, nil}
          end

        requirements_expression = build_requirements_expression([rules], facts, filter)

        if expr do
          {:and, expr, requirements_expression}
        else
          requirements_expression
        end
      end)

    expression
    |> add_negations_and_solve()
    |> get_all_scenarios(expression)
    |> case do
      [] ->
        {:error, :unsatisfiable}

      scenarios ->
        {:ok,
         scenarios
         |> Enum.uniq()
         |> remove_irrelevant_clauses()}
    end
  end

  defp get_all_scenarios(scenario_result, expression, scenarios \\ [])
  defp get_all_scenarios({:error, :unsatisfiable}, _, scenarios), do: scenarios

  defp get_all_scenarios({:ok, scenario}, expression, scenarios) do
    expression
    |> add_negations_and_solve([scenario | scenarios])
    |> get_all_scenarios(expression, [scenario | scenarios])
  end

  defp remove_irrelevant_clauses(scenarios) do
    new_scenarios =
      scenarios
      |> Enum.uniq()
      |> Enum.map(fn scenario ->
        unnecessary_fact =
          Enum.find_value(scenario, fn
            {_fact, :unknowable} ->
              false

            # TODO: Is this acceptable?
            # If the check refers to empty data, and its meant to bypass strict checks
            # Then we consider that fact an irrelevant fact? Probably.
            {_fact, :irrelevant} ->
              true

            {fact, value_in_this_scenario} ->
              matching =
                Enum.find(scenarios, fn potential_irrelevant_maker ->
                  potential_irrelevant_maker != scenario &&
                    Map.delete(scenario, fact) == Map.delete(potential_irrelevant_maker, fact)
                end)

              case matching do
                %{^fact => value} when is_boolean(value) and value != value_in_this_scenario ->
                  fact

                _ ->
                  false
              end
          end)

        Map.delete(scenario, unnecessary_fact)
      end)
      |> Enum.uniq()

    if new_scenarios == scenarios do
      new_scenarios
    else
      remove_irrelevant_clauses(new_scenarios)
    end
  end

  defp add_negations_and_solve(requirements_expression, negations \\ []) do
    negations =
      Enum.reduce(negations, nil, fn negation, expr ->
        negation_statement =
          negation
          |> Map.drop([true, false])
          |> facts_to_statement()

        if expr do
          {:and, expr, {:not, negation_statement}}
        else
          {:not, negation_statement}
        end
      end)

    full_expression =
      if negations do
        {:and, requirements_expression, negations}
      else
        requirements_expression
      end

    {bindings, expression} = extract_bindings(full_expression)

    expression
    |> to_conjunctive_normal_form()
    |> lift_clauses()
    |> negations_to_negative_numbers()
    |> picosat_solve()
    |> solutions_to_predicate_values(bindings)
  end

  defp picosat_solve(equation) do
    Picosat.solve(equation)
  end

  defp facts_to_statement(facts) do
    Enum.reduce(facts, nil, fn {fact, true?}, expr ->
      expr_component =
        if true? do
          fact
        else
          {:not, fact}
        end

      if expr do
        {:and, expr, expr_component}
      else
        expr_component
      end
    end)
  end

  defp build_requirements_expression(sets_of_rules, facts, filter) do
    rules_expression =
      Enum.reduce(sets_of_rules, nil, fn rules, acc ->
        case acc do
          nil ->
            compile_rules_expression(rules, facts, filter)

          expr ->
            {:and, expr, compile_rules_expression(rules, facts, filter)}
        end
      end)

    facts =
      Enum.reduce(facts, %{}, fn {key, value}, acc ->
        if value == :unknowable do
          acc
        else
          Map.put(acc, key, value)
        end
      end)

    facts_expression = facts_to_statement(facts)

    if facts_expression do
      {:and, facts_expression, rules_expression}
    else
      rules_expression
    end
  end

  defp solutions_to_predicate_values({:ok, solution}, bindings) do
    scenario =
      Enum.reduce(solution, %{true: [], false: []}, fn var, state ->
        fact = Map.get(bindings, abs(var))

        Map.put(state, fact, var > 0)
      end)

    {:ok, scenario}
  end

  defp solutions_to_predicate_values({:error, error}, _), do: {:error, error}

  defp compile_rules_expression([{:authorize_if, clause}], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} -> true
      {:ok, false} -> false
      {:ok, :unknowable} -> false
      {:ok, :irrelevant} -> true
      :error -> Clause.expression(clause)
    end
  end

  defp compile_rules_expression([{:authorize_if, clause} | rest], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} ->
        true

      {:ok, false} ->
        compile_rules_expression(rest, facts, filter)

      {:ok, :irrelevant} ->
        true

      {:ok, :unknowable} ->
        compile_rules_expression(rest, facts, filter)

      :error ->
        {:or, Clause.expression(clause), compile_rules_expression(rest, facts, filter)}
    end
  end

  defp compile_rules_expression([{:authorize_unless, clause}], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} ->
        false

      {:ok, false} ->
        true

      {:ok, :irrelevant} ->
        true

      {:ok, :unknowable} ->
        false

      :error ->
        {:not, Clause.expression(clause)}
    end
  end

  defp compile_rules_expression([{:authorize_unless, clause} | rest], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} ->
        compile_rules_expression(rest, facts, filter)

      {:ok, false} ->
        true

      {:ok, :irrelevant} ->
        true

      {:ok, :unknowable} ->
        compile_rules_expression(rest, facts, filter)

      :error ->
        {:or, {:not, Clause.expression(clause)}, compile_rules_expression(rest, facts, filter)}
    end
  end

  defp compile_rules_expression([{:forbid_if, _clause}], _facts, _) do
    false
  end

  defp compile_rules_expression([{:forbid_if, clause} | rest], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} ->
        false

      {:ok, :irrelevant} ->
        compile_rules_expression(rest, facts, filter)

      {:ok, :unknowable} ->
        false

      {:ok, false} ->
        compile_rules_expression(rest, facts, filter)

      :error ->
        {:and, {:not, Clause.expression(clause)}, compile_rules_expression(rest, facts, filter)}
    end
  end

  defp compile_rules_expression([{:forbid_unless, _clause}], _facts, _id) do
    false
  end

  defp compile_rules_expression([{:forbid_unless, clause} | rest], facts, filter) do
    clause = %{clause | filter: filter}

    case Clause.find(facts, clause) do
      {:ok, true} ->
        compile_rules_expression(rest, facts, filter)

      {:ok, false} ->
        false

      {:ok, :irrelevant} ->
        false

      {:ok, :unknowable} ->
        false

      :error ->
        {:and, Clause.expression(clause), compile_rules_expression(rest, facts, filter)}
    end
  end

  defp extract_bindings(expr, bindings \\ %{current: 1})

  defp extract_bindings({operator, left, right}, bindings) do
    {bindings, left_extracted} = extract_bindings(left, bindings)
    {bindings, right_extracted} = extract_bindings(right, bindings)

    {bindings, {operator, left_extracted, right_extracted}}
  end

  defp extract_bindings({:not, value}, bindings) do
    {bindings, extracted} = extract_bindings(value, bindings)

    {bindings, {:not, extracted}}
  end

  defp extract_bindings(value, %{current: current} = bindings) do
    current_binding =
      Enum.find(bindings, fn {key, binding_value} ->
        key != :current && binding_value == value
      end)

    case current_binding do
      nil ->
        new_bindings =
          bindings
          |> Map.put(:current, current + 1)
          |> Map.put(current, value)

        {new_bindings, current}

      {binding, _} ->
        {bindings, binding}
    end
  end

  # A helper function for formatting to the same output we'd give to picosat
  @doc false
  def to_picosat(clauses, variable_count) do
    clause_count = Enum.count(clauses)

    formatted_input =
      Enum.map_join(clauses, "\n", fn clause ->
        format_clause(clause) <> " 0"
      end)

    "p cnf #{variable_count} #{clause_count}\n" <> formatted_input
  end

  defp negations_to_negative_numbers(clauses) do
    Enum.map(
      clauses,
      fn
        {:not, var} when is_integer(var) ->
          [negate_var(var)]

        var when is_integer(var) ->
          [var]

        clause ->
          Enum.map(clause, fn
            {:not, var} -> negate_var(var)
            var -> var
          end)
      end
    )
  end

  defp negate_var(var, multiplier \\ -1)

  defp negate_var({:not, value}, multiplier) do
    negate_var(value, multiplier * -1)
  end

  defp negate_var(value, multiplier), do: value * multiplier

  defp format_clause(clause) do
    Enum.map_join(clause, " ", fn
      {:not, var} -> "-#{var}"
      var -> "#{var}"
    end)
  end

  # {:and, {:or, 1, 2}, {:and, {:or, 3, 4}, {:or, 5, 6}}}

  # [[1, 2], [3]]

  # TODO: Is this so simple?
  defp lift_clauses({:and, left, right}) do
    lift_clauses(left) ++ lift_clauses(right)
  end

  defp lift_clauses({:or, left, right}) do
    [lift_or_clauses(left) ++ lift_or_clauses(right)]
  end

  defp lift_clauses(value), do: [[value]]

  defp lift_or_clauses({:or, left, right}) do
    lift_or_clauses(left) ++ lift_or_clauses(right)
  end

  defp lift_or_clauses(value), do: [value]

  defp to_conjunctive_normal_form(expression) do
    expression
    |> demorgans_law()
    |> distributive_law()
  end

  defp distributive_law(expression) do
    distributive_law_applied = apply_distributive_law(expression)

    if expression == distributive_law_applied do
      expression
    else
      distributive_law(distributive_law_applied)
    end
  end

  defp apply_distributive_law({:or, left, {:and, right1, right2}}) do
    left_distributed = apply_distributive_law(left)

    {:and, {:or, left_distributed, apply_distributive_law(right1)},
     {:or, left_distributed, apply_distributive_law(right2)}}
  end

  defp apply_distributive_law({:or, {:and, left1, left2}, right}) do
    right_distributed = apply_distributive_law(right)

    {:and, {:or, apply_distributive_law(left1), right_distributed},
     {:or, apply_distributive_law(left2), right_distributed}}
  end

  defp apply_distributive_law({:not, expression}) do
    {:not, apply_distributive_law(expression)}
  end

  defp apply_distributive_law({operator, left, right}) when operator in [:and, :or] do
    {operator, apply_distributive_law(left), apply_distributive_law(right)}
  end

  defp apply_distributive_law(var) when is_integer(var) do
    var
  end

  defp demorgans_law(expression) do
    demorgans_law_applied = apply_demorgans_law(expression)

    if expression == demorgans_law_applied do
      expression
    else
      demorgans_law(demorgans_law_applied)
    end
  end

  defp apply_demorgans_law({:not, {:and, left, right}}) do
    {:or, {:not, apply_demorgans_law(left)}, {:not, apply_demorgans_law(right)}}
  end

  defp apply_demorgans_law({:not, {:or, left, right}}) do
    {:and, {:not, left}, {:not, right}}
  end

  defp apply_demorgans_law({operator, left, right}) when operator in [:or, :and] do
    {operator, apply_demorgans_law(left), apply_demorgans_law(right)}
  end

  defp apply_demorgans_law({:not, expression}) do
    {:not, apply_demorgans_law(expression)}
  end

  defp apply_demorgans_law(var) when is_integer(var) do
    var
  end
end
