defmodule DigiBattleCrawler.ImageDownloader do
  @base_url "https://digi-battle.com/"
  def download(url, card_number) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!(Crawly.Utils.build_absolute_url(url, @base_url))

    image_path = Path.join([File.cwd!(), "tmp/images/#{card_number}.png"])
    File.write!(image_path, body)
  end
end
