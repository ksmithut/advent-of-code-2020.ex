defmodule AdventOfCode.Day23 do
  alias __MODULE__.{Cups, Cup}

  @doc ~S"""
  ## Examples

      iex> part1("389125467", 10)
      "92658374"

  """
  def part1(input, moves \\ 100) do
    cups =
      parse_input(input)
      |> Cups.new()
      |> play(moves)
      |> elem(1)

    Cups.get(cups, 1)
    |> (&Cups.next(cups, &1)).()
    |> (&part_1_output(cups, &1)).()
  end

  @doc ~S"""
  ## Examples

      iex> part2("389125467")
      149245887792

  """
  def part2(input) do
    items = parse_input(input)
    extra = length(items)..1_000_000

    {head, cups} =
      Enum.concat(items, extra)
      |> Cups.new()
      |> play(10_000_000)

    after_1 = Cups.next(cups, head)
    after_2 = Cups.next(cups, after_1)
    Cup.value(after_1) * Cup.value(after_2)
  end

  defp parse_input(input) do
    String.trim(input)
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp play(state, times) when times <= 0, do: state

  defp play({head, cups}, times) do
    next_1 = Cups.next(cups, head)
    next_2 = Cups.next(cups, next_1)
    next_3 = Cups.next(cups, next_2)
    after_next = Cups.next(cups, next_3)

    destination =
      find(
        cups,
        [next_1, next_2, next_3],
        Cup.value(head) - 1
      )

    after_destination = Cups.next(cups, destination)

    cups =
      cups
      |> Cups.set_next(head, after_next)
      |> Cups.set_next(destination, next_1)
      |> Cups.set_next(next_3, after_destination)

    play({Cups.get(cups, Cup.value(after_next)), cups}, times - 1)
  end

  defp find(cups, ignore, 0), do: find(cups, ignore, Cups.size(cups))

  defp find(cups, ignore, value) do
    cup = Cups.get(cups, value)

    cond do
      cup === nil -> find(cups, ignore, value - 1)
      cup in ignore -> find(cups, ignore, value - 1)
      true -> cup
    end
  end

  defp part_1_output(cups, cup) do
    case Cup.value(cup) do
      1 -> ""
      val -> "#{val}#{part_1_output(cups, Cups.next(cups, cup))}"
    end
  end
end

defmodule AdventOfCode.Day23.Cups do
  defstruct data: %{}, size: 0
  alias __MODULE__
  alias AdventOfCode.Day23.Cup

  def new(list) do
    cups_array =
      list
      |> Enum.map(&Cup.new/1)

    size = length(cups_array)

    data =
      cups_array
      |> Stream.with_index()
      |> Stream.map(fn {cup, index} ->
        rem(index + 1, size)
        |> (&Enum.at(cups_array, &1)).()
        |> Cup.value()
        |> (&Cup.set_next(cup, &1)).()
      end)
      |> Stream.map(fn cup -> {Cup.value(cup), cup} end)
      |> Map.new()

    head = Map.get(data, Enum.at(list, 0))

    {head, %Cups{data: data, size: size}}
  end

  def get(%Cups{data: data}, value), do: Map.get(data, value)
  def next(%Cups{data: data}, cup), do: Map.get(data, Cup.next(cup))
  def size(%Cups{size: size}), do: size

  def set_next(%Cups{data: data} = cups, cup, next) do
    data = Map.put(data, Cup.value(cup), Cup.set_next(cup, Cup.value(next)))
    %Cups{cups | data: data}
  end
end

defmodule AdventOfCode.Day23.Cup do
  defstruct value: nil, next: nil
  alias __MODULE__

  def new(value), do: %Cup{value: value}
  def value(%Cup{value: value}), do: value
  def next(%Cup{next: next}), do: next
  def set_next(%Cup{} = cup, next), do: %Cup{cup | next: next}
end
