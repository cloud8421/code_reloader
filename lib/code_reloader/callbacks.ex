defmodule CodeReloader.Callbacks do
  defmacro __using__(_) do
    quote do
      def recompile do
        CodeReloader.Commands.recompile
        :ok
      end

      defoverridable recompile: 0
    end
  end
end
