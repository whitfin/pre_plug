defmodule PrePlug do
  @moduledoc """
  This module is gross, but it's my current solution to the issue being tracked
  inside https://github.com/elixir-lang/plug/issues/409. Basically, we need a
  way to make sure that certain plugs are executed before the execution of the
  `try` context inside `Plug.ErrorHandler`. We do this by simply overriding the
  `call/2` function and passing the executed plugs to the `super`.

  It should be noted that you  must `use PrePlug` **after**
  importing any other functions which override `call/2`. This is because the
  overrides in this module would become pointless if overridden.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      # we need to execute the `__before_compile__` of PrePlug
      @before_compile PrePlug

      # we need a module attribute to track the defined `:pre_plugs`
      Module.register_attribute(__MODULE__, :pre_plugs, accumulate: true)

      # import this module to allow the use of the Macros
      import PrePlug, only: [pre_plug: 1, pre_plug: 2]
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    # parse out any builder options
    pre_plugs    = Module.get_attribute(env.module, :pre_plugs)
    builder_opts = Module.get_attribute(env.module, :plug_builder_opts)

    # compile the pre plugs using the Plug Builder
    {conn, body} = Plug.Builder.compile(env, pre_plugs, builder_opts)

    # override call to execute first
    quote location: :keep do
      defoverridable [call: 2]

      # pipe the pre-conn to the super function
      def call(unquote(conn), opts) do
        unquote(body) |> super(opts)
      end
    end
  end

  @doc """
  A macro that stores a new pre-plug. `opts` will be passed unchanged to the new
  plug.

  This macro doesn't add any guards when adding the new plug to the pipeline;
  for more information about adding plugs with guards see `Plug.Builder.compile/1`.

  ## Examples

      pre_plug Plug.Logger               # pre_plug module
      pre_plug :foo, some_options: true  # pre_plug function

  """
  defmacro pre_plug(plug, opts \\ []) do
    quote do
      @pre_plugs {unquote(plug), unquote(opts), true}
    end
  end

end
