defmodule DigiBattleCrawler.ImageDownloader do
  @base_url "https://digi-battle.com/"
  def download(url, card_number) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!(Crawly.Utils.build_absolute_url(url, @base_url))

    images_dir = Path.join([File.cwd!(), "tmp", "images"])
    File.mkdir_p!(images_dir)
    File.write!(Path.join([images_dir, "#{card_number}.png"]), body)
  end
end
