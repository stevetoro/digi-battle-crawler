defmodule DigiBattleCrawler.DigimonParser do
  alias DigiBattleCrawler.DigimonParser
  alias DigiBattleCrawler.ImageDownloader

  defstruct document: nil,
            sidepane: nil,
            wide_table: nil,
            digimon: %{
              name: nil,
              card_number: nil,
              group: nil,
              level: nil,
              battle_type: nil,
              attacks: %{red: nil, green: nil, yellow: nil},
              card_set: nil,
              card_type: nil,
              special_effect: nil,
              digimon_type: nil,
              special_ability: nil,
              scores: %{
                rookie: nil,
                champion: nil,
                ultimate: nil,
                mega: nil
              },
              card_image: nil
            },
            card_image_url: nil

  def parse(document) do
    %DigimonParser{document: document}
    |> find_sidepane()
    |> find_wide_table()
    |> parse_digimon_name()
    |> parse_card_number()
    |> parse_digimon_group()
    |> parse_digimon_level()
    |> parse_digimon_battle_type()
    |> parse_digimon_attacks()
    |> parse_wide_table_attributes()
    |> parse_card_image_url()
    |> download_card_scan()
    |> then(fn p -> p.digimon end)
  end

  defp find_sidepane(%DigimonParser{document: document} = parser) do
    sidepane =
      document
      |> Floki.find(".card-details-sidepane")

    %DigimonParser{parser | sidepane: sidepane}
  end

  defp find_wide_table(%DigimonParser{document: document} = parser) do
    wide_table =
      document
      |> Floki.find(".wide-table tr>td:nth-child(2)")
      |> Enum.map(fn x -> Floki.text(x) end)

    %DigimonParser{parser | wide_table: wide_table}
  end

  defp parse_digimon_name(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    name = sidepane |> Floki.find("#EnglishName") |> Floki.text()
    %DigimonParser{parser | digimon: %{digimon | name: name}}
  end

  defp parse_card_number(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    card_number = sidepane |> Floki.find(".serial-code") |> Floki.text()
    %DigimonParser{parser | digimon: %{digimon | card_number: card_number}}
  end

  defp parse_digimon_group(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    group = sidepane |> Floki.find("#EnglishDescription") |> Floki.text()
    %DigimonParser{parser | digimon: %{digimon | group: group}}
  end

  defp parse_digimon_level(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    level = sidepane |> Floki.find("#EnglishDigimonLevel") |> Floki.text()
    %DigimonParser{parser | digimon: %{digimon | level: level}}
  end

  defp parse_digimon_battle_type(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    battle_type =
      sidepane
      |> Floki.find(".battle-type")
      |> Enum.at(0)
      |> Floki.attribute("class")
      |> Enum.at(0)
      |> String.replace("battle-type ", "")

    %DigimonParser{parser | digimon: %{digimon | battle_type: battle_type}}
  end

  defp parse_digimon_attacks(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    [red, green, yellow] =
      sidepane |> Floki.find(".row.w-100 > .col-12 div")

    %DigimonParser{
      parser
      | digimon: %{
          digimon
          | attacks: %{
              red: parse_attack(red),
              green: parse_attack(green),
              yellow: parse_attack(yellow)
            }
        }
    }
  end

  defp parse_attack({_, _, [name_element, power_element]}) do
    name = name_element |> Floki.text()
    power = power_element |> String.trim() |> String.replace("- ", "")
    %{name: name, power: power}
  end

  defp parse_wide_table_attributes(
         %DigimonParser{wide_table: wide_table, digimon: digimon} = parser
       ) do
    %DigimonParser{
      parser
      | digimon: %{
          digimon
          | card_set: Enum.at(wide_table, 0),
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
    }
  end

  defp parse_card_image_url(%DigimonParser{document: document} = parser) do
    card_image_url = document |> Floki.find("#CardSmall") |> Floki.attribute("src") |> Enum.at(0)
    %DigimonParser{parser | card_image_url: card_image_url}
  end

  defp download_card_scan(
         %DigimonParser{
           card_image_url: card_image_url,
           digimon: %{card_set: card_set, card_number: card_number} = digimon
         } =
           parser
       ) do
    ImageDownloader.download(card_image_url, card_set, card_number)
    %DigimonParser{parser | digimon: %{digimon | card_image: "#{card_set}/#{card_number}.png"}}
  end
end
