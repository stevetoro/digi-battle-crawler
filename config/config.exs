import Config

config :crawly,
  pipelines: [
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "./tmp"}
  ]
