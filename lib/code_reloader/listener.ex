defmodule CodeReloader.Listener do
  require Logger

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary,
                                           packet: :line,
                                           active: false,
                                           reuseaddr: true])
    Logger.debug "Code reloader accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(CodeReloader.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case read_line(socket) do
      {:ok, command} ->
        case (command |> String.strip |> exec) do
          :ok ->
            write_line("ok", socket)
          :error ->
            write_line("unknown command\r\n", socket)
        end
        serve(socket)
      error -> error
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  defp exec("recompile") do
    CodeReloader.Commands.recompile
    :ok
  end
  defp exec(_command) do
    :error
  end
end
