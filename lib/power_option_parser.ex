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
              restrictions: []
            },
            card_image_url: nil

  def parse(document) do
    %PowerOptionParser{document: document}
    |> parse_name()
    |> parse_card_number()
    |> parse_card_set()
    |> parse_type()
    |> parse_effect()
    |> parse_restrictions()
    |> parse_card_image_url()
    |> download_card_scan()
    |> then(fn p -> p.power_option end)
  end

  defp parse_name(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    name = document |> Floki.find("#EnglishPOName") |> Floki.text()
    %PowerOptionParser{parser | power_option: %{power_option | name: name}}
  end

  defp parse_card_number(
         %PowerOptionParser{document: document, power_option: power_option} = parser
       ) do
    card_number = document |> Floki.find(".serial-code") |> Floki.text()
    %PowerOptionParser{parser | power_option: %{power_option | card_number: card_number}}
  end

  defp parse_card_set(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    card_set = document |> Floki.find("h5:fl-contains('Set:') a") |> Floki.text()
    %PowerOptionParser{parser | power_option: %{power_option | card_set: card_set}}
  end

  defp parse_type(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    type = document |> Floki.find("h5:fl-contains('Type:') span") |> Floki.text()
    %PowerOptionParser{parser | power_option: %{power_option | type: type}}
  end

  defp parse_effect(%PowerOptionParser{document: document, power_option: power_option} = parser) do
    effect = document |> Floki.find("#EnglishPOEffect") |> Floki.text()
    %PowerOptionParser{parser | power_option: %{power_option | effect: effect}}
  end

  defp parse_restrictions(
         %PowerOptionParser{document: document, power_option: power_option} = parser
       ) do
    restrictions =
      document |> Floki.find("#EnglishRestrictions li") |> Enum.map(fn x -> Floki.text(x) end)

    %PowerOptionParser{parser | power_option: %{power_option | restrictions: restrictions}}
  end

  defp parse_card_image_url(%PowerOptionParser{document: document} = parser) do
    card_image_url = document |> Floki.find("#CardSmall") |> Floki.attribute("src") |> Enum.at(0)
    %PowerOptionParser{parser | card_image_url: card_image_url}
  end

  defp download_card_scan(
         %PowerOptionParser{
           card_image_url: card_image_url,
           power_option: %{card_number: card_number}
         } =
           parser
       ) do
    ImageDownloader.download(card_image_url, card_number)
    parser
  end
end
