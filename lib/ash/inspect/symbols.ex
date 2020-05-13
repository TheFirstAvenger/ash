defmodule Ash.Inspect.Symbols do
  @moduledoc """
  Helpers for outputting report symbols
  Color codes are taken from https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
  """

  @check_mark "✓"
  @x_mark "✗"
  @defer_mark "↓"

  @question_mark "?"
  @stop_mark "⊘"
  @dash_mark "-"

  def code(code, text) do
    IO.ANSI.color(code) <> text <> IO.ANSI.reset()
  end

  def x_mark(), do: code(9, @x_mark)
  def check_mark(), do: code(10, @check_mark)
  def defer_mark(), do: code(14, @defer_mark)

  def question_mark(), do: code(11, @question_mark)
  def stop_mark(), do: code(1, @stop_mark)
  def dash_mark(), do: code(8, @dash_mark)

  def legend() do
    IO.puts(x_mark() <> " x_mark")
    IO.puts(check_mark() <> " check_mark")
    IO.puts(defer_mark() <> " defer_mark")
    IO.puts(question_mark() <> " question_mark")
    IO.puts(stop_mark() <> " stop_mark")
    IO.puts(dash_mark() <> " dash_mark")
  end
end
