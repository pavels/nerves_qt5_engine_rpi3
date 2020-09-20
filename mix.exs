defmodule NervesQt5EngineRpi3.MixProject do
  use Mix.Project

  @github_organization "pavels"
  @app :nerves_qt5_engine_rpi3
  @source_url "https://github.com/#{@github_organization}/#{@app}"
  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.6",
      compilers: Mix.compilers() ++ [:nerves_package],
      nerves_package: nerves_package(),
      description: description(),
      package: package(),
      deps: deps(),
      aliases: [loadconfig: [&bootstrap/1], docs: ["docs", &copy_images/1]],
      docs: docs(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.build": :docs,
        "hex.publish": :docs
      }
    ]
  end

  def application do
    []
  end

  defp bootstrap(args) do
    set_target()
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :nerves_qt5_engine,
      artifact_sites: [
        {:github_releases, "#{@github_organization}/#{@app}"}
      ],
      build_runner_opts: build_runner_opts(),
      platform: NervesQt5EngineBuild.Build,
      platform_config: [
        defconfig: "build_config.mk"
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves_qt5_engine_build, path: "../nerves_qt5_engine_build", runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:nerves_system_linter, "~> 0.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Nerves QT5 Engine - Raspberry Pi 3 B / B+
    """
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp package_files do
    [
      "CHANGELOG.md",
      "LICENSE",
      "mix.exs",
      "README.md",
      "VERSION"
    ]
  end

  # Copy the images referenced by docs, since ex_doc doesn't do this.
  defp copy_images(_) do
    File.cp_r("assets", "doc/assets")
  end

  defp build_runner_opts() do
    []
  end

  defp set_target() do
    if function_exported?(Mix, :target, 1) do
      apply(Mix, :target, [:target])
    else
      System.put_env("MIX_TARGET", "target")
    end
  end
end
