defmodule DigiBattleCrawler.PowerOptionParser do
  def parse(document) do
    name = document |> Floki.find("#EnglishPOName") |> Floki.text()
    card_set = document |> Floki.find("h5:fl-contains('Set:') a") |> Floki.text()
    card_number = document |> Floki.find(".serial-code") |> Floki.text()
    type = document |> Floki.find("h5:fl-contains('Type:') span") |> Floki.text()
    effect = document |> Floki.find("#EnglishPOEffect") |> Floki.text()

    restrictions =
      document |> Floki.find("#EnglishRestrictions li") |> Enum.map(fn x -> Floki.text(x) end)

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
