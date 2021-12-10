defmodule Prob1 do

  def solve do
    # {:ok, content} = File.read("day7input.txt")

    frequencies = IO.read(:stdio, :all)
      |> String.trim_trailing
      |> String.split(",")
      |> Enum.map(&elem(Integer.parse(&1),0))
      |> Enum.frequencies
      |> Enum.into([])

    all_pos_fuels = frequencies |> Enum.sort_by(&(elem(&1, 0))) |> calc_all_pos_fuels(:asc)
    all_pos_desc_fuels = frequencies |> Enum.sort_by(&(elem(&1, 0)), :desc) |> calc_all_pos_fuels(:desc)

    # IO.inspect all_pos_fuels
    # IO.inspect all_pos_desc_fuels

    answer = Enum.zip(all_pos_fuels, Enum.reverse(all_pos_desc_fuels))
      |> Enum.map(fn {%{fuel: forward_fuel, pos: pos}, %{fuel: backward_fuel}} -> {forward_fuel - backward_fuel, pos} end)
      |> Enum.min_by(&(elem(&1, 0)))

    # IO.inspect answer
    IO.puts elem(answer, 0)
  end

  def calc_all_pos_fuels(frequencies, dir) do
    step = case dir do
      :asc -> 1
      :desc -> -1
    end

    start_pos = elem(List.first(frequencies),0) - step
    frequencies
      |> Enum.flat_map_reduce(
        %{crabs_below_pos: 0, fuel: 0, pos: start_pos},
        fn {curr_pos, num_crabs}, %{crabs_below_pos: crabs_below_prev_pos, fuel: prev_fuel, pos: prev_pos} ->
          {
            Enum.map(
              prev_pos+step..curr_pos,
              fn p -> %{pos: p, fuel: prev_fuel + crabs_below_prev_pos * (p - prev_pos)} end),
            %{
              crabs_below_pos: crabs_below_prev_pos + num_crabs,
              fuel: prev_fuel + crabs_below_prev_pos * (curr_pos - prev_pos),
              pos: curr_pos
            }
          }
        end)
      |> elem(0)
  end
end

Prob1.solve
