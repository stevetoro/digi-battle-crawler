defmodule DigiBattleCrawler do
  use Crawly.Spider
  alias DigiBattleCrawler.DigimonParser
  alias DigiBattleCrawler.PowerOptionParser

  @impl Crawly.Spider
  def base_url, do: "https://digi-battle.com"

  @impl Crawly.Spider
  def init do
    [
      start_urls: [
        "https://digi-battle.com/Sets/StarterSet",
        "https://digi-battle.com/Sets/BoosterSet1",
        "https://digi-battle.com/Sets/BoosterSet2",
        "https://digi-battle.com/Sets/StarterSetHoloChaseCards",
        "https://digi-battle.com/Sets/MoviePromo",
        "https://digi-battle.com/Sets/TacoBellPromo",
        "https://digi-battle.com/Sets/FoxKidsPromo"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    requests =
      document
      |> Floki.find(".gallery a")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        url
        |> Crawly.Utils.build_absolute_url(response.request_url)
        |> Crawly.Utils.request_from_url()
      end)

    items =
      cond do
        DigimonParser.parseable?(document) ->
          [DigimonParser.parse(document)]

        PowerOptionParser.parseable?(document) ->
          [PowerOptionParser.parse(document)]

        true ->
          []
      end

    %Crawly.ParsedItem{
      :requests => requests,
      :items => items
    }
  end
end
