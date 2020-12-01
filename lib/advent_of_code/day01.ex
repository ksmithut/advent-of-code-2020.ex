defmodule AdventOfCode.Day01 do
  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day01.part1("1721\n979\n366\n299\n675\n1456")
      514579

      iex> AdventOfCode.Day01.part2("1721\n979\n366\n299\n675\n1456")
      241861950

  """
  def part1(input) do
    parse_input(input)
    |> find_pair_sum(2020)
    |> (fn {a, b} -> a * b end).()
  end

  def part2(input) do
    parse_input(input)
    |> find_trio_sum(2020)
    |> (fn {a, b, c} -> a * b * c end).()
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_pair_sum(list, sum) do
    Enum.find_value(list, fn a ->
      Enum.find_value(list, fn b ->
        cond do
          a === b -> nil
          a + b === sum -> {a, b}
          true -> nil
        end
      end)
    end)
  end

  defp find_trio_sum(list, sum) do
    Enum.find_value(list, fn a ->
      Enum.find_value(list, fn b ->
        Enum.find_value(list, fn c ->
          cond do
            a === b -> nil
            a === c -> nil
            b === c -> nil
            a + b + c === sum -> {a, b, c}
            true -> nil
          end
        end)
      end)
    end)
  end
end
