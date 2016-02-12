# CodeReloader

Experimental application that allows to recompile and restart an Elixir application via a tcp command.

## Installation

This package can be installed via:

  1. Add code_reloader to your list of dependencies in `mix.exs`:

        def deps do
          [{:code_reloader, github: "cloud8421/code_reloader", only: :dev}]
        end

  2. Ensure code_reloader is started before your application:

        def application do
          [applications: [:plug, :cowboy, etc...] ++ code_reloader_app(Mix.env)]
        end

        defp code_reloader_app(:dev) do
          [:code_reloader]
        end
        defp code_reloader_app(_), do: []

     **IMPORTANT** Please make sure that the application is started only in
     `dev` as shown in the example above.

  3. Configure the needed port in `config.exs`:

        config :code_reloader,
          port: 9999

## Usage

Once up, you can send tcp commands to the istance, for example with [nmap](https://nmap.org/).

    $ echo "recompile" | ncat localhost 9999
