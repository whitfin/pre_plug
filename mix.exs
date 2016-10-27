defmodule PrePlug.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/pre_plug"
  @url_github "https://github.com/zackehh/pre_plug"

  def project do
    [
      app: :pre_plug,
      name: "PrePlug",
      description: "Plugs with guaranteed effects in error handlers",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE",
          "README.md"
        ],
        licenses: [ "MIT" ],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        },
        maintainers: [ "Isaac Whitfield" ]
      },
      version: "0.1.0",
      elixir: "~> 1.2",
      deps: deps,
      docs: [
        extras: [ "README.md" ],
        source_ref: "master",
        source_url: @url_github
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :plug]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{ :plug, "~> 1.2", optional: true }]
  end
end
