defmodule FuzzyCast.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuzzy_cast,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      # Docs
      name: "FuzzyCast",
      source_url: "https://github.com/pyramind10/fuzzy_cast",
      docs: [
        main: "FuzzyCast",
        extras: ["README.md"]
      ]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0.0"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Composing introspective %like% queries for Ecto.Schema fields."
  end

  defp package() do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/pyramind10/fuzzy_cast"}
    ]
  end
end
