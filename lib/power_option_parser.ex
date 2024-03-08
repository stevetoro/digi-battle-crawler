defmodule DigiBattleCrawler.PowerOptionParser do
  alias DigiBattleCrawler.PowerOptionParser
  alias DigiBattleCrawler.ImageDownloader

  defstruct document: nil,
            power_option: %{
              name: nil,
              card_type: "Power Option",
              card_set: nil,
              card_number: nil,
              type: nil,
              effect: nil,
              restrictions: [],
              card_image: nil
            },
            card_image_url: nil

  def parseable?(document) do
    document |> Floki.find("#EnglishPOName") |> Enum.any?()
  end

  def parse(document) do
    %PowerOptionParser{document: document}
    |> set_name
    |> set_card_number
    |> set_card_set
    |> set_type
    |> set_effect
    |> set_restrictions
    |> set_card_image_url
    |> download_card_image
    |> then(& &1.power_option)
  end

  defp set_name(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    document
    |> Floki.find("#EnglishPOName")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | name: &1}})
  end

  defp set_card_number(
         %PowerOptionParser{document: document, power_option: power_option} = parser
       ) do
    document
    |> Floki.find(".serial-code")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | card_number: &1}})
  end

  defp set_card_set(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    document
    |> Floki.find("h5:fl-contains('Set:') a")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | card_set: &1}})
  end

  defp set_type(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    document
    |> Floki.find("h5:fl-contains('Type:') span")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | type: &1}})
  end

  defp set_effect(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    document
    |> Floki.find("#EnglishPOEffect")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | effect: &1}})
  end

  defp set_restrictions(
         %PowerOptionParser{document: document, power_option: power_option} = parser
       ) do
    document
    |> Floki.find("#EnglishRestrictions li")
    |> Enum.map(fn x -> Floki.text(x) end)
    |> then(&%PowerOptionParser{parser | power_option: %{power_option | restrictions: &1}})
  end

  defp set_card_image_url(%PowerOptionParser{document: document} = parser) do
    document
    |> Floki.find("#CardSmall")
    |> Floki.attribute("src")
    |> Floki.text()
    |> then(&%PowerOptionParser{parser | card_image_url: &1})
  end

  defp download_card_image(
         %PowerOptionParser{
           card_image_url: card_image_url,
           power_option: %{card_set: card_set, card_number: card_number} = power_option
         } = parser
       ) do
    {:ok, image_location} = ImageDownloader.download(card_image_url, card_set, card_number)
    %PowerOptionParser{parser | power_option: %{power_option | card_image: image_location}}
  end
end
