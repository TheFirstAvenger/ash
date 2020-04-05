defmodule Ash.Authorization.Report do
  alias Ash.Authorization.Clause

  defstruct [
    :scenarios,
    :requests,
    :facts,
    :strict_check_facts,
    :state,
    :strict_access?,
    :header,
    :authorized?,
    :reason,
    no_steps_configured: false
  ]

  def report(%{no_steps_configured: %Ash.Engine.Request{} = request}) do
    "forbidden:\n" <>
      request.source <> ": no authorization steps configured. Resource: #{request.resource}"
  end

  # We know that each group of authorization steps shares the same relationship
  def report(report) do
    header = (report.header || "Authorization Report") <> "\n"

    explained_steps =
      case report.state do
        %{data: data} when data not in [[], nil] ->
          explain_steps_with_data(
            report.requests,
            report.facts,
            List.wrap(data),
            report.strict_access?
          )

        _ ->
          if report.strict_access? do
            "\n\n\nAuthorization run with `strict_access?: true`. This is the only safe way to authorize requests for lists of filtered data.\n" <>
              "Some checks may still fetch data from the database, like filters on related data when their primary key was given.\n" <>
              explain_steps(report.requests, report.facts, report.strict_access?)
          else
            explain_steps(report.requests, report.facts, report.strict_access?)
          end
      end

    explained_facts = explain_facts(report.facts, report.strict_check_facts || %{})

    reason =
      if report.reason do
        "\n" <> report.reason <> "\n"
      else
        ""
      end

    main_message =
      header <> reason <> indent("Facts Gathered\n" <> indent(explained_facts) <> explained_steps)

    if report.authorized? do
      main_message
    else
      main_message <> indent("\n\nScenarios:\n" <> indent(explain_scenarios(report.scenarios)))
    end
  end

  defp explain_scenarios(scenarios) when scenarios in [nil, []] do
    """
    No scenarios found. Under construction.
    Eventually, scenarios will explain what data you could change to make the request possible.
    """
  end

  defp explain_scenarios(scenarios) do
    """
    #{Enum.count(scenarios)} found. Under construction.
    Eventually, scenarios will explain what data you could change to make the request possible.
    """
  end

  defp explain_steps_with_data(requests, facts, data, strict_access?) do
    title = "\n\nAuthorization Steps:\n\n"

    contents =
      requests
      |> Enum.map_join("\n---\n", fn request ->
        relationship = request.relationship
        resource = request.resource

        inner_title =
          if relationship == [] do
            request.source <> " -> " <> inspect(resource) <> ": "
          else
            Enum.join(relationship, ".") <> " - " <> inspect(resource) <> ": "
          end

        full_inner_title =
          if request.bypass_strict_access? && strict_access? do
            inner_title <> " (bypass strict access)"
          else
            inner_title
          end

        rules_legend =
          request.rules
          |> Enum.with_index()
          |> Enum.map_join("\n", fn {{step, check}, index} ->
            "#{index + 1}| " <>
              to_string(step) <> ": " <> check.check_module.describe(check.check_opts)
          end)

        pkey = Ash.primary_key(resource)

        # TODO: data has to change with relationships
        data_info =
          data
          |> Enum.map(fn item ->
            formatted =
              item
              |> Map.take(pkey)
              |> format_pkey()

            {formatted, Map.take(item, pkey)}
          end)
          |> add_header_line(indent("Record"))
          |> pad()
          |> add_step_info(request.rules, facts)

        full_inner_title <>
          ":\n" <> indent(rules_legend <> "\n\n" <> data_info <> "\n")
      end)

    title <> indent(contents)
  end

  defp add_step_info([header | rest], steps, facts) do
    key = Enum.join(1..Enum.count(steps), "|")

    header <>
      indent(
        " |" <>
          key <>
          "|\n" <>
          do_add_step_info(rest, steps, facts)
      )
  end

  defp do_add_step_info(pkeys, steps, facts) do
    Enum.map_join(pkeys, "\n", fn {pkey_line, pkey} ->
      steps
      |> Enum.reduce({true, pkey_line <> " "}, fn
        {_step, _clause}, {false, string} ->
          {false, string <> "|~"}

        {step, clause}, {true, string} ->
          status =
            case Clause.find(facts, %{clause | pkey: pkey}) do
              {:ok, value} -> value
              _ -> nil
            end

          mark = step_to_mark(step, status)

          new_mark =
            if mark == "↓" do
              "→"
            else
              mark
            end

          continue? = new_mark not in ["✓", "✗"]

          {continue?, string <> "|" <> new_mark}
      end)
      |> elem(1)
      |> Kernel.<>("|")
    end)
  end

  defp add_header_line(lines, title) do
    [title | lines]
  end

  defp pad(lines) do
    longest =
      lines
      |> Enum.map(fn
        {line, _pkey} ->
          String.length(line)

        line ->
          String.length(line)
      end)
      |> Enum.max()

    Enum.map(
      lines,
      fn
        {line, pkey} ->
          length = String.length(line)

          {line <> String.duplicate(" ", longest - length), pkey}

        line ->
          length = String.length(line)

          line <> String.duplicate(" ", longest - length)
      end
    )
  end

  defp explain_facts(facts, strict_check_facts) do
    facts
    |> Map.drop([true, false])
    |> Enum.group_by(fn {clause, _status} ->
      clause.pkey
    end)
    |> Enum.sort_by(fn {pkey, _} -> not is_nil(pkey) end)
    |> Enum.map_join("\n---\n", fn {pkey, clauses_and_statuses} ->
      title = format_pkey(pkey) <> " facts"

      contents =
        clauses_and_statuses
        |> Enum.group_by(fn {clause, _} ->
          {clause.source, clause.path}
        end)
        |> Enum.sort_by(fn {{_, relationship}, _} ->
          {Enum.count(relationship), relationship}
        end)
        |> Enum.map_join("\n", fn {{source, relationship}, clauses_and_statuses} ->
          contents =
            Enum.map_join(clauses_and_statuses, "\n", fn {clause, status} ->
              gets_star? =
                Clause.find(strict_check_facts, clause) in [
                  {:ok, true},
                  {:ok, false}
                ]

              star =
                if gets_star? do
                  " ⭑"
                else
                  ""
                end

              mod = clause.check_module
              opts = clause.check_opts

              status_to_mark(status) <> " " <> mod.describe(opts) <> star
            end)

          if relationship == [] do
            indent(contents)
          else
            operation =
              if source == :side_load do
                "SideLoad "
              else
                "Related "
              end

            operation <> Enum.join(relationship, ".") <> ":\n" <> indent(contents)
          end
        end)

      title <> ":\n" <> contents
    end)
  end

  defp format_pkey(nil), do: "Root"

  defp format_pkey(pkey) do
    if Enum.count(pkey) == 1 do
      pkey |> Enum.at(0) |> elem(1) |> to_string()
    else
      Enum.map_join(pkey, ",", fn {key, value} -> to_string(key) <> ":" <> to_string(value) end)
    end
  end

  defp status_to_mark(true), do: "✓"
  defp status_to_mark(false), do: "✗"
  defp status_to_mark(:unknowable), do: "?"
  defp status_to_mark(:irrelevant), do: "⊘"
  defp status_to_mark(nil), do: "-"

  defp indent(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line -> "  " <> line end)
    |> Enum.join("\n")
  end

  defp explain_steps(requests, facts, strict_access?) do
    title = "\n\nAuthorization Steps:\n"

    contents =
      Enum.map_join(requests, "\n------\n", fn request ->
        title =
          if request.bypass_strict_access? && strict_access? do
            request.source <> " (bypass strict access)"
          else
            request.source
          end

        contents =
          request.rules
          |> Enum.sort_by(fn {_step, clause} ->
            {Enum.count(clause.path), clause.path}
          end)
          |> Enum.map(fn {step, clause} ->
            status =
              case Clause.find(facts, clause) do
                {:ok, value} -> value
                _ -> nil
              end

            status_mark = status_to_mark(status)
            step_mark = step_to_mark(step, status)

            mod = clause.check_module
            opts = clause.check_opts
            relationship = clause.path

            if relationship == [] do
              step_mark <>
                " | " <> to_string(step) <> ": " <> mod.describe(opts) <> " " <> status_mark
            else
              step_mark <>
                " | " <>
                to_string(step) <>
                ": #{Enum.join(relationship, ".")}: " <>
                mod.describe(opts) <> " " <> status_mark
            end
          end)
          |> Enum.join("\n")

        title <> ":\n" <> indent(contents)
      end)

    title <> indent(contents)
  end

  defp step_to_mark(:authorize_if, true), do: "✓"
  defp step_to_mark(:authorize_if, false), do: "↓"
  defp step_to_mark(:authorize_if, _), do: "↓"

  defp step_to_mark(:forbid_if, true), do: "✗"
  defp step_to_mark(:forbid_if, false), do: "↓"
  defp step_to_mark(:forbid_if, _), do: "✗"

  defp step_to_mark(:authorize_unless, true), do: "↓"
  defp step_to_mark(:authorize_unless, false), do: "✓"
  defp step_to_mark(:authorize_unless, _), do: "↓"

  defp step_to_mark(:forbid_unless, true), do: "↓"
  defp step_to_mark(:forbid_unless, false), do: "✗"
  defp step_to_mark(:forbid_unless, _), do: "✗"
end
