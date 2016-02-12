defmodule CodeReloader do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      supervisor(Task.Supervisor, [[name: CodeReloader.TaskSupervisor]]),
      worker(Task, [CodeReloader.Listener, :accept, [port]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeReloader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    Application.get_env(:code_reloader, :port, 9999)
  end
end
