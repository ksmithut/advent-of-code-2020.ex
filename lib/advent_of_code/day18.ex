defmodule AdventOfCode.Day18 do
  @doc ~S"""
  ## Examples

      iex> part1("1 + 2 * 3 + 4 * 5 + 6")
      71

      iex> part1("1 + (2 * 3) + (4 * (5 + 6))")
      51

      iex> part1("2 * 3 + (4 * 5)")
      26

      iex> part1("5 + (8 * 3 + 9 + 3 * 4 * 3)")
      437

      iex> part1("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
      12240

      iex> part1("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
      13632

  """
  def part1(input) do
    parse_input(input)
    |> Stream.map(&evaluate/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples


      iex> part2("1 + (2 * 3) + (4 * (5 + 6))")
      51

      iex> part2("2 * 3 + (4 * 5)")
      46

      iex> part2("5 + (8 * 3 + 9 + 3 * 4 * 3)")
      1445

      iex> part2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
      669060

      iex> part2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
      23340

  """
  def part2(input) do
    parse_input(input, %{"+" => 2, "*" => 1})
    |> Stream.map(&evaluate/1)
    |> Enum.sum()
  end

  defp parse_input(input, prec \\ %{"+" => 1, "*" => 1}) do
    String.split(input, "\n", trim: true)
    |> Stream.map(&tokenize(&1, prec))
  end

  defp tokenize("", _), do: []
  defp tokenize(" " <> rest, prec), do: tokenize(rest, prec)
  defp tokenize("(" <> rest, prec), do: [:left_paren | tokenize(rest, prec)]
  defp tokenize(")" <> rest, prec), do: [:right_paren | tokenize(rest, prec)]

  defp tokenize("+" <> rest, %{"+" => token_prec} = prec),
    do: [{:op, token_prec, &+/2} | tokenize(rest, prec)]

  defp tokenize("*" <> rest, %{"*" => token_prec} = prec),
    do: [{:op, token_prec, &*/2} | tokenize(rest, prec)]

  defp tokenize(<<digit::bytes-size(1)>> <> rest, prec),
    do: [{:num, String.to_integer(digit)} | tokenize(rest, prec)]

  @spec evaluate([any()], [integer()], [atom()]) :: number()
  defp evaluate(tokens, values \\ [], operators \\ [])

  defp evaluate([{:num, num} | tokens], values, operators),
    do: evaluate(tokens, [num | values], operators)

  defp evaluate([:left_paren | tokens], values, operators),
    do: evaluate(tokens, values, [:left_paren | operators])

  defp evaluate([:right_paren | tokens], values, [:left_paren | operators]),
    do: evaluate(tokens, values, operators)

  defp evaluate([:right_paren | _] = tokens, [a, b | values], [{:op, _, op} | operators]),
    do: evaluate(tokens, [op.(a, b) | values], operators)

  defp evaluate([{:op, op_precedence, _} | _] = tokens, [a, b | values], [
         {:op, top_precedence, op} | operators
       ])
       when top_precedence >= op_precedence,
       do: evaluate(tokens, [op.(a, b) | values], operators)

  defp evaluate([{:op, _, _} = token | tokens], values, operators),
    do: evaluate(tokens, values, [token | operators])

  defp evaluate([], [a, b | values], [{:op, _, op} | operators]),
    do: evaluate([], [op.(a, b) | values], operators)

  defp evaluate([], [value], []), do: value
end
