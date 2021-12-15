defmodule Prob2 do

  def solve do
    frequencies = IO.read(:stdio, :all)
      |> String.trim_trailing
      |> String.split(",")
      |> Enum.map(&elem(Integer.parse(&1),0))
      |> Enum.frequencies
      |> Enum.into([])

    # IO.inspect frequencies

    all_pos_fuels = frequencies |> Enum.sort_by(&(elem(&1, 0))) |> calc_all_pos_fuels(:asc)
    all_pos_desc_fuels = frequencies |> Enum.sort_by(&(elem(&1, 0)), :desc) |> calc_all_pos_fuels(:desc)

    # IO.inspect all_pos_fuels
    # IO.inspect all_pos_desc_fuels

    answer = Enum.zip(all_pos_fuels, Enum.reverse(all_pos_desc_fuels))
      |> Enum.map(fn {%{fuel: forward_fuel, pos: pos}, %{fuel: backward_fuel}} -> {forward_fuel + backward_fuel, pos} end)
      |> Enum.min_by(&(elem(&1, 0)))

    # answer has also the pos info
    # IO.inspect answer
    IO.puts elem(answer, 0)
  end

  def calc_all_pos_fuels(frequencies, dir) do
    step = case dir do
      :asc -> 1
      :desc -> -1
    end

    start_pos = elem(List.first(frequencies),0) - step

    crabs_and_fuels_at_each_pos = frequencies
      |> Enum.flat_map_reduce(
        %{pos: start_pos, crabs_at_prev_pos: []},
        fn {curr_pos, num_crabs}, %{pos: prev_pos, crabs_at_prev_pos: crabs_at_prev_pos} ->
          { crabs_between, last_pos_crabs } = Enum.flat_map_reduce(
            prev_pos+step..curr_pos,
            crabs_at_prev_pos,
            fn this_pos, prev_crabs ->
              this_pos_crabs = prev_crabs |> Enum.map(& %{&1 | move_fuel: &1[:move_fuel] + 1})
              { [%{pos: this_pos, crabs_at_prev_pos: this_pos_crabs }], this_pos_crabs }
            end)
          {
            crabs_between,
            %{
              pos: curr_pos,
              crabs_at_prev_pos: [ %{crabs: num_crabs, move_fuel: 0} | last_pos_crabs]
            }
          }
        end)
      |> elem(0)
    # IO.inspect crabs_and_fuels_at_each_pos

    Enum.scan(crabs_and_fuels_at_each_pos, %{fuel: 0}, fn %{pos: pos, crabs_at_prev_pos: crabs}, acc ->
      acc_fuel = acc[:fuel] + (Enum.map(crabs, & &1[:crabs] * &1[:move_fuel]) |> Enum.sum)
      %{pos: pos, fuel: acc_fuel}
    end)
  end
end

Prob2.solve
