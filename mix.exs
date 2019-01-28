defmodule UeberauthMarvin.MixProject do
  use Mix.Project

	@version "0.1.0"
	@url "https://github.com/plantran/ueberauth_marvin"

  def project do
    [
      app: :ueberauth_marvin,
      version: @version,
			name: "Ueberauth Marvin Strategy",
      elixir: "~> 1.7",
			build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
			source_url: @url,
      homepage_url: @url,
      description: description(),
      deps: deps(),
			docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :oauth2, :ueberauth]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
			{:oauth2, "~> 0.9.4"},
			{:ueberauth, "~> 0.5.0"},

			{:credo, "~> 1.0", only: [:dev, :test]},
			{:earmark, "~> 1.3", only: :dev},
			{:ex_doc, "~> 0.19.3", only: :dev},
    ]
  end

	defp docs do
    [extras: ["README.md", "CONTRIBUTING.md"]]
  end

	defp description do
		"An Uberauth strategy for 42's intranet."
	end

	defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Paula Lantran"],
     licenses: ["MIT"],
     links: %{"GitHub": @url}]
  end
end
