defmodule ComplexNumber.MixProject do
  use Mix.Project

  def project do
    [
      app: :complex_number,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage:
        if System.get_env("CI") do
          [tool: :covertool]
        else
          []
        end,
      source_url: "https://github.com/h-ikeda/complex_number",
      # docs: [logo: "logo.svg"],
      description: "Complex number operations.",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/h-ikeda/complex_number"}
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:covertool, "~> 2.0", only: [:test]},
      {:ex_doc, "~> 0.23", only: [:dev], runtime: false}
    ]
  end
end
