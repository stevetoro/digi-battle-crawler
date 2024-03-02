defmodule DigiBattleCrawler do
  use Crawly.Spider
  alias DigiBattleCrawler.DigimonParser, as: DigimonParser

  @impl Crawly.Spider
  def base_url, do: "https://digi-battle.com"

  @impl Crawly.Spider
  def init do
    [
      start_urls: [
        "https://digi-battle.com/Sets/StarterSet",
        "https://digi-battle.com/Sets/BoosterSet1",
        "https://digi-battle.com/Sets/BoosterSet2"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items =
      cond do
        card_set_page?(response.request_url) ->
          []

        card_detail_page?(response.request_url) ->
          [DigimonParser.parse(document)]
      end

    requests =
      document
      |> Floki.find(".gallery a")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        Crawly.Utils.build_absolute_url(url, response.request_url)
        |> Crawly.Utils.request_from_url()
      end)

    %Crawly.ParsedItem{
      :items => items,
      :requests => requests
    }
  end

  defp card_set_page?(request_url) do
    request_url |> String.contains?("/Sets/")
  end

  defp card_detail_page?(request_url) do
    request_url |> String.contains?("/Card/Details/")
  end
end
