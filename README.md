# DigiBattleCrawler

An Elixir web crawler for Digimon Digi-Battle card game data.

## Requirements

1. Elixir 1.17.2
2. Erlang/OTP 26

Your mileage may vary with other versions of Elixir/OTP.

## Run

```bash
git clone https://github.com/stevetoro/digi-battle-crawler.git
cd digi-battle-crawler
iex -S mix run -e "Crawly.Engine.start_spider(DigiBattleCrawler)"
```

The card data and images will be put in the `tmp` directory at the project root.
