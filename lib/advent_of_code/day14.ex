defmodule AdventOfCode.Day14 do
  alias AdventOfCode.Day14.BitMask

  @doc ~S"""
  ## Examples

      iex> part1("mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X\nmem[8] = 11\nmem[7] = 101\nmem[8] = 0")
      165

      iex> part2("mask = 000000000000000000000000000000X1001X\nmem[42] = 100\nmask = 00000000000000000000000000000000X0XX\nmem[26] = 1")
      208

  """
  def part1(input) do
    parse_input(input)
    |> Enum.reduce({%{}, nil}, fn
      {:mask, mask}, {memory, _old_mask} ->
        {memory, mask}

      {:mem, address, value}, {memory, mask} ->
        {Map.put(memory, address, BitMask.apply(mask, value)), mask}
    end)
    |> elem(0)
    |> Map.values()
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.reduce({%{}, nil}, fn
      {:mask, mask}, {memory, _old_mask} ->
        {memory, mask}

      {:mem, address, value}, {memory, mask} ->
        memory =
          BitMask.apply_floating(mask, address)
          |> Enum.reduce(memory, fn address, memory ->
            Map.put(memory, address, value)
          end)

        {memory, mask}
    end)
    |> elem(0)
    |> Map.values()
    |> List.flatten()
    |> Enum.sum()
  end

  defp parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn
      "mask = " <> mask ->
        {:mask, BitMask.new(mask)}

      line ->
        %{"address" => address, "value" => value} =
          Regex.named_captures(~r/^mem\[(?<address>\d+)\] = (?<value>\d+)/, line)

        {:mem, String.to_integer(address), String.to_integer(value)}
    end)
  end
end

defmodule AdventOfCode.Day14.BitMask do
  defstruct mask: []
  alias __MODULE__

  def new(input) do
    mask =
      String.graphemes(input)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn
        {"X", index} -> {:floating, index}
        {bit, index} -> {String.to_integer(bit), index}
      end)

    %BitMask{mask: mask}
  end

  def apply(%BitMask{mask: mask}, num) do
    digits = Integer.digits(num, 2) |> Enum.reverse()

    mask
    |> Enum.map(fn
      {:floating, index} -> Enum.at(digits, index, 0)
      {bit, _} -> bit
    end)
    |> Enum.reverse()
    |> Integer.undigits(2)
  end

  def apply_floating(%BitMask{mask: mask}, address) do
    digits = Integer.digits(address, 2) |> Enum.reverse()

    mask
    |> Enum.map(fn
      {:floating, _} -> :floating
      {0, index} -> Enum.at(digits, index, 0)
      {1, _} -> 1
    end)
    |> floating_combos()
    |> Enum.map(fn result ->
      Enum.reverse(result) |> Integer.undigits(2)
    end)
  end

  defp floating_combos(result) do
    case Enum.find_index(result, fn val -> val === :floating end) do
      nil ->
        [result]

      index ->
        Enum.concat(
          List.replace_at(result, index, 0) |> floating_combos(),
          List.replace_at(result, index, 1) |> floating_combos()
        )
    end
  end
end
