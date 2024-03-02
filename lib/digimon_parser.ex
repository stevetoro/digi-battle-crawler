defmodule DigiBattleCrawler.DigimonParser do
  def parse(document) do
    sidepane = parse_side_pane(document)
    wide_table = parse_wide_table(document)
    Map.merge(sidepane, wide_table)
  end

  defp parse_side_pane(document) do
    sidepane =
      document
      |> Floki.find(".card-details-sidepane")

    name = sidepane |> Floki.find("#EnglishName") |> Floki.text()
    card_number = sidepane |> Floki.find(".serial-code") |> Floki.text()
    group = sidepane |> Floki.find("#EnglishDescription") |> Floki.text()
    level = sidepane |> Floki.find("#EnglishDigimonLevel") |> Floki.text()

    battle_type =
      sidepane
      |> Floki.find(".battle-type")
      |> Enum.at(0)
      |> Floki.attribute("class")
      |> Enum.at(0)
      |> String.replace("battle-type ", "")

    [red, green, yellow] =
      sidepane |> Floki.find(".row.w-100 > .col-12 div")

    %{
      name: name,
      card_number: card_number,
      group: group,
      level: level,
      battle_type: battle_type,
      attacks: %{
        red: parse_attack(red),
        green: parse_attack(green),
        yellow: parse_attack(yellow)
      }
    }
  end

  defp parse_attack({_, _, [name_element, power_element]}) do
    name = name_element |> Floki.text()
    power = power_element |> String.trim() |> String.replace("- ", "")
    %{name: name, power: power}
  end

  defp parse_wide_table(document) do
    wide_table =
      document
      |> Floki.find(".wide-table tr>td:nth-child(2)")
      |> Enum.map(fn x -> Floki.text(x) end)

    %{
      card_set: Enum.at(wide_table, 0),
      card_type: Enum.at(wide_table, 1),
      special_effect: Enum.at(wide_table, 2),
      digimon_type: Enum.at(wide_table, 3),
      special_ability: Enum.at(wide_table, 4),
      scores: %{
        rookie: Enum.at(wide_table, 5),
        champion: Enum.at(wide_table, 6),
        ultimate: Enum.at(wide_table, 7),
        mega: Enum.at(wide_table, 8)
      }
    }
  end
end
