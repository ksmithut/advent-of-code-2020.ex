defmodule AdventOfCode.Day08 do
  alias __MODULE__.BootCode

  @doc ~S"""
  ## Examples

      iex> AdventOfCode.Day08.part1("nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6")
      5

      iex> AdventOfCode.Day08.part2("nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6")
      8

  """
  def part1(input) do
    BootCode.new(input)
    |> BootCode.run_until_first_repeat()
    |> Tuple.to_list()
    |> Enum.at(1)
  end

  def part2(input) do
    boot_code = BootCode.new(input)

    Enum.with_index(boot_code.instructions)
    |> Enum.map(fn
      {{"jmp", _}, index} ->
        BootCode.replace_op(boot_code, index, "nop")

      {{"nop", _}, index} ->
        BootCode.replace_op(boot_code, index, "jmp")

      _ ->
        boot_code
    end)
    |> Enum.find_value(fn boot_code ->
      BootCode.run_while(boot_code, fn position, visited ->
        Map.get(visited, position, 0) < 10
      end)
      |> case do
        {:ok, value} -> value
        {:break, _} -> nil
      end
    end)
  end
end

defmodule AdventOfCode.Day08.BootCode do
  defstruct instructions: []
  alias __MODULE__

  @line_regex ~r/^(?<instruction>\w+) (?<sign>\+|-)(?<amount>\d+)$/
  def new(input) do
    instructions =
      String.trim(input)
      |> String.split("\n")
      |> Enum.map(fn line ->
        %{"instruction" => instruction, "sign" => sign, "amount" => amount} =
          Regex.named_captures(@line_regex, line)

        amount = String.to_integer(amount)

        amount =
          case sign do
            "+" -> amount
            "-" -> amount * -1
          end

        {instruction, amount}
      end)

    %BootCode{instructions: instructions}
  end

  def replace_op(%BootCode{instructions: instructions}, position, instruction) do
    {_, amount} = Enum.at(instructions, position)
    instructions = List.replace_at(instructions, position, {instruction, amount})
    %BootCode{instructions: instructions}
  end

  def run_until_first_repeat(%BootCode{} = boot_code) do
    run_while(boot_code, fn position, visited ->
      !Map.has_key?(visited, position)
    end)
  end

  def run_while(
        %BootCode{instructions: instructions} = boot_code,
        while,
        position \\ 0,
        value \\ 0,
        visited \\ %{}
      ) do
    cond do
      position >= Enum.count(instructions) ->
        {:ok, value}

      while.(position, visited) == false ->
        {:break, value}

      true ->
        visited = Map.put(visited, position, Map.get(visited, position, 0) + 1)

        case Enum.at(instructions, position) do
          {"acc", amount} ->
            run_while(boot_code, while, position + 1, value + amount, visited)

          {"jmp", amount} ->
            run_while(boot_code, while, position + amount, value, visited)

          {"nop", _} ->
            run_while(boot_code, while, position + 1, value, visited)
        end
    end
  end
end
