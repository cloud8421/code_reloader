defmodule CodeReloader.Listener do
  require Logger

  def accept(port, callbacks) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary,
                                           packet: :line,
                                           active: false,
                                           reuseaddr: true])
    Logger.debug "Code reloader accepting connections on port #{port}"
    loop_acceptor(socket, callbacks)
  end

  defp loop_acceptor(socket, callbacks) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(CodeReloader.TaskSupervisor, fn -> serve(client, callbacks) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, callbacks)
  end

  defp serve(socket, callbacks) do
    case read_line(socket) do
      {:ok, command} ->
        case (command |> String.strip |> exec(callbacks)) do
          :ok ->
            write_line("ok", socket)
          :error ->
            write_line("unknown command\r\n", socket)
        end
        serve(socket, callbacks)
      error -> error
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  defp exec("recompile", callbacks) do
    callbacks.recompile
    :ok
  end
  defp exec(_command, _callbacks) do
    :error
  end
end
