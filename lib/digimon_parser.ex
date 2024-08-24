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
              digivolution_requirements: nil,
              attacks: %{red: nil, green: nil, yellow: nil},
              card_set: nil,
              card_type: "Digimon",
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

  def parseable?(document) do
    document |> Floki.find("#EnglishName") |> Enum.any?()
  end

  def parse(document) do
    %DigimonParser{document: document}
    |> set_sidepane
    |> set_wide_table
    |> set_digimon_name
    |> set_card_number
    |> set_digimon_group
    |> set_digimon_level
    |> set_digimon_battle_type
    |> set_digivolution_requirements
    |> set_digimon_attacks
    |> set_digimon_card_set
    |> set_digimon_special_effect
    |> set_digimon_type
    |> set_card_image_url
    |> set_special_ability
    |> set_digimon_scores
    |> download_card_image
    |> then(& &1.digimon)
  end

  defp set_sidepane(%DigimonParser{document: document} = parser) do
    document
    |> Floki.find(".card-details-sidepane")
    |> then(&%DigimonParser{parser | sidepane: &1})
  end

  defp set_wide_table(%DigimonParser{document: document} = parser) do
    document
    |> Floki.find(".wide-table tr")
    |> Enum.reduce(%{}, fn att, acc ->
      att
      |> Floki.find("td")
      |> Enum.map(fn x -> Floki.text(x) end)
      |> then(fn [key, val] -> Map.put(acc, key, val) end)
    end)
    |> then(&%DigimonParser{parser | wide_table: &1})
  end

  defp set_digimon_name(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    sidepane
    |> Floki.find("#EnglishName")
    |> Floki.text()
    |> then(&%DigimonParser{parser | digimon: %{digimon | name: &1}})
  end

  defp set_card_number(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    sidepane
    |> Floki.find(".serial-code")
    |> Floki.text()
    |> then(&%DigimonParser{parser | digimon: %{digimon | card_number: &1}})
  end

  defp set_digimon_group(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    sidepane
    |> Floki.find("#EnglishDescription")
    |> Floki.text()
    |> then(&%DigimonParser{parser | digimon: %{digimon | group: &1}})
  end

  defp set_digimon_level(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    sidepane
    |> Floki.find("#EnglishDigimonLevel")
    |> Floki.text()
    |> then(&%DigimonParser{parser | digimon: %{digimon | level: &1}})
  end

  defp set_digimon_battle_type(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    sidepane
    |> Floki.find(".row.mb-2.p-0 .battle-type")
    |> Floki.attribute("class")
    |> Floki.text()
    |> String.replace("battle-type", "")
    |> String.trim()
    |> then(&%DigimonParser{parser | digimon: %{digimon | battle_type: &1}})
  end

  defp set_digivolution_requirements(
         %DigimonParser{sidepane: sidepane, digimon: digimon} = parser
       ) do
    requirements = sidepane |> Floki.find(".row.mb-2.p-0 li")

    parsed_requirements =
      cond do
        contains_dna?(requirements) ->
          parse_digivolution_requirements(requirements, "DNA")

        contains_armor?(requirements) ->
          parse_digivolution_requirements(requirements, "ARMOR")

        true ->
          parse_digivolution_requirements(requirements)
      end

    %DigimonParser{parser | digimon: %{digimon | digivolution_requirements: parsed_requirements}}
  end

  defp contains_dna?(requirements) do
    requirements |> Floki.text() |> String.contains?("(DNA)")
  end

  defp contains_armor?(requirements) do
    requirements |> Floki.text() |> String.contains?("(ARMOR)")
  end

  defp parse_digivolution_requirements(requirements, special) do
    Enum.map(requirements, fn req ->
      req
      |> Floki.text()
      |> String.replace("(#{special}) - ", "")
      |> String.split("+")
      |> Enum.map(&String.trim(&1))
      |> then(&[special | &1])
    end)
  end

  defp parse_digivolution_requirements(requirements) do
    Enum.map(requirements, fn req ->
      req
      |> Floki.text()
      |> String.split("+")
      |> Enum.map(&String.trim(&1))
    end)
  end

  defp set_digimon_attacks(%DigimonParser{sidepane: sidepane, digimon: digimon} = parser) do
    [red, green, yellow] =
      sidepane
      |> Floki.find(".row.w-100 > .col-12 div")
      |> Enum.map(&parse_digimon_attack/1)

    %DigimonParser{
      parser
      | digimon: %{digimon | attacks: %{red: red, green: green, yellow: yellow}}
    }
  end

  defp parse_digimon_attack({_, _, [name, power]}) do
    %{
      name: name |> Floki.text(),
      power: power |> String.replace("-", "") |> String.trim()
    }
  end

  defp set_digimon_card_set(%DigimonParser{wide_table: wide_table, digimon: digimon} = parser) do
    wide_table
    |> Map.get("Card Set")
    |> then(&%DigimonParser{parser | digimon: %{digimon | card_set: &1}})
  end

  defp set_digimon_special_effect(
         %DigimonParser{wide_table: wide_table, digimon: digimon} = parser
       ) do
    wide_table
    |> Map.get("Special Effect")
    |> then(&%DigimonParser{parser | digimon: %{digimon | special_effect: &1}})
  end

  defp set_digimon_type(%DigimonParser{wide_table: wide_table, digimon: digimon} = parser) do
    wide_table
    |> Map.get("Digimon Type")
    |> then(&%DigimonParser{parser | digimon: %{digimon | digimon_type: &1}})
  end

  defp set_special_ability(%DigimonParser{wide_table: wide_table, digimon: digimon} = parser) do
    wide_table
    |> Map.get("Special Ability")
    |> then(&%DigimonParser{parser | digimon: %{digimon | special_ability: &1}})
  end

  defp set_digimon_scores(%DigimonParser{wide_table: wide_table, digimon: digimon} = parser) do
    %DigimonParser{
      parser
      | digimon: %{
          digimon
          | scores: %{
              rookie: Map.get(wide_table, "Rookie Score"),
              champion: Map.get(wide_table, "Champion Score"),
              ultimate: Map.get(wide_table, "Ultimate Score"),
              mega: Map.get(wide_table, "Mega Score")
            }
        }
    }
  end

  defp set_card_image_url(%DigimonParser{document: document} = parser) do
    document
    |> Floki.find("#CardSmall")
    |> Floki.attribute("src")
    |> Floki.text()
    |> then(&%DigimonParser{parser | card_image_url: &1})
  end

  defp download_card_image(
         %DigimonParser{
           card_image_url: card_image_url,
           digimon: %{card_set: card_set, card_number: card_number} = digimon
         } = parser
       ) do
    {:ok, image_location} = ImageDownloader.download(card_image_url, card_set, card_number)
    %DigimonParser{parser | digimon: %{digimon | card_image: image_location}}
  end
end
