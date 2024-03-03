# DigiBattleCrawler

An Elixir web crawler for Digimon Digi-Battle card game data.

## Quickstart

1. Clone and cd into this repository
2. mkdir tmp && mkdir tmp/images
3. iex -S mix run -e "Crawly.Engine.start_spider(DigiBattleCrawler)"

Wait for Crawly to do its thing and you'll find your card data and images in the `tmp` directory at the project root.

I wrote this with Elixir 1.16. YMMV on another version of Elixir.
