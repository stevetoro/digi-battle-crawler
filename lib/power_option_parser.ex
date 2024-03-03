defmodule DigiBattleCrawler.PowerOptionParser do
  alias DigiBattleCrawler.ImageDownloader

  def parse(document) do
    card_number = document |> Floki.find(".serial-code") |> Floki.text()
    card_image_url = document |> Floki.find("#CardSmall") |> Floki.attribute("src") |> Enum.at(0)
    name = document |> Floki.find("#EnglishPOName") |> Floki.text()
    card_set = document |> Floki.find("h5:fl-contains('Set:') a") |> Floki.text()
    type = document |> Floki.find("h5:fl-contains('Type:') span") |> Floki.text()
    effect = document |> Floki.find("#EnglishPOEffect") |> Floki.text()

    restrictions =
      document |> Floki.find("#EnglishRestrictions li") |> Enum.map(fn x -> Floki.text(x) end)

    ImageDownloader.download(card_image_url, card_number)

    %{
      name: name,
      card_type: "Power Option",
      card_set: card_set,
      card_number: card_number,
      type: type,
      effect: effect,
      restrictions: restrictions
    }
  end
end
