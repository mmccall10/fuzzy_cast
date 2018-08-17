defmodule FuzzyCast.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuzzy_cast,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "FuzzyCast",
      source_url: "https://github.com/pyramind10/fuzzy_cast",
      docs: [
        main: "FuzzyCast",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end
end
