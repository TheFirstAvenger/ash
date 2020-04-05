defmodule Ash.Error.Forbidden do
  @moduledoc "Raised when authorization for an action fails"

  alias Ash.Authorization.Report

  defexception [
    :scenarios,
    :requests,
    :facts,
    :strict_check_facts,
    :state,
    :strict_access?,
    :reason,
    no_steps_configured: false
  ]

  def message(error) do
    report = %Report{
      reason: error.reason,
      scenarios: error.scenarios,
      requests: error.requests,
      facts: error.facts,
      strict_check_facts: error.strict_check_facts,
      state: error.state,
      strict_access?: error.strict_access?,
      no_steps_configured: error.no_steps_configured,
      header: "forbidden:",
      authorized?: false
    }

    Report.report(report)
  end

  def report_text(error, header \\ "forbidden:") do
    report = %Report{
      reason: error.reason,
      scenarios: error.scenarios,
      requests: error.requests,
      facts: error.facts,
      strict_check_facts: error.strict_check_facts,
      state: error.state,
      strict_access?: error.strict_access?,
      no_steps_configured: error.no_steps_configured,
      header: header,
      authorized?: false
    }

    Report.report(report)
  end
end
