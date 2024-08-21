defmodule DigiBattleCrawler do
  use Crawly.Spider
  alias DigiBattleCrawler.DigimonParser

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

    requests =
      document
      |> Floki.find(".gallery a")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        Crawly.Utils.build_absolute_url(url, response.request_url)
        |> Crawly.Utils.request_from_url()
      end)

    %Crawly.ParsedItem{
      :items => parse(document),
      :requests => requests
    }
  end

  defp parse(document) do
    cond do
      digimon_card?(document) -> [DigimonParser.parse(document)]
      true -> []
    end
  end

  defp digimon_card?(document) do
    document |> Floki.find("#EnglishName") |> Enum.any?()
  end
end
