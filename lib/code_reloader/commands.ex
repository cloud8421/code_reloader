defmodule CodeReloader.Commands do
  @moduledoc """
  The module collects commands that can be run in the target application.
  """
  @doc """
  This code has been extracted from Iex, see: <https://github.com/elixir-lang/elixir/blob/master/lib/iex/lib/iex/helpers.ex#L56-L93>
  """
  def recompile do
    if mix_started? do
      config = Mix.Project.config
      reenable_tasks(config)
      case stop_apps(config) do
        {true, apps} ->
          Mix.Task.run("app.start")
          {:restarted, apps}
        {false, apps} ->
          Mix.Task.run("app.start", ["--no-start"])
          {:recompiled, apps}
      end
    else
      IO.puts IEx.color(:eval_error, "Mix is not running. Please start IEx with: iex -S mix")
      :error
    end
  end

  defp reenable_tasks(config) do
    Mix.Task.reenable("app.start")
    Mix.Task.reenable("compile")
    Mix.Task.reenable("compile.all")
    compilers = config[:compilers] || Mix.compilers
    Enum.each compilers, &Mix.Task.reenable("compile.#{&1}")
  end

  defp stop_apps(config) do
    apps =
      cond do
        Mix.Project.umbrella?(config) ->
          for %Mix.Dep{app: app} <- Mix.Dep.Umbrella.loaded, do: app
        app = config[:app] ->
          [app]
        true ->
          []
      end
    stopped? =
      Enum.reverse(apps)
      |> Enum.filter(&(&1 != :code_reloader))
      |> Enum.all?(&match?({:error, {:not_started, &1}}, Application.stop(&1)))
      |> Kernel.not
    {stopped?, apps}
  end

  defp mix_started? do
    List.keyfind(Application.started_applications, :mix, 0) != nil
  end
end
