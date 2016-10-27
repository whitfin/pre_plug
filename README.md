# PrePlug

By default, if you're using an error handler and an error is thrown inside Plug, you lose your entire chain of things registered to happen in `:before_send` (because you don't have changes reflected in the connection) - meaning that for things like request logging and monitoring, Plug is extremely awkward. Please see the example a little further down for more information. This module provides a workaround for [this issue](https://github.com/elixir-lang/plug/issues/409). My hope is that this eventually gets into Plug somehow, but until then I quite simply must have a way to do this.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `pre_plug` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:pre_plug, "~> 0.1.0"}]
    end
    ```

  2. Ensure `pre_plug` is started before your application:

    ```elixir
    def application do
      [applications: [:pre_plug]]
    end
    ```

## Usage

Pretty easy, just `use PrePlug` and use `pre_plug` instead of `plug` for all of the Plugs which you require always take effect regardless of error. Be vigilant with this, and only use `pre_plug` when you absolutely must in order to avoid any unintended side effects (not that I know of any, but better safe than sorry).

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use PrePlug

  # pre_plug as it must always fire properly
  pre_plug Plug.Logger

  # plug for anything else
  plug :match
  plug :dispatch
end
```

## Examples

In order to explain this properly, there needs to be an example (as Plug is very misleading here).

Consider the router below, and pay close attention to the Logger:

```elixir
defmodule PlugTest.Router do
  # import Conn
  import Plug.Conn

  # pull in any Plug dependencies
  use Plug.ErrorHandler
  use Plug.Router

  # add first plug
  plug Plug.Logger

  # plug requirements
  plug :match
  plug :dispatch

  get "/" do
    raise Plug.BadRequestError
  end

  defp handle_errors(conn, _) do
    send_resp(conn, conn.status, "Something went wrong!")
  end
end
```

All looks typical right? Nothing special, just the built in Plug routing tools. However, if you call this endpoint, you'll see this in your terminal output:

```elixir
00:06:35.396 [info]  GET /
```

The Logger fired the initial log which happens on request start, but the log intended to fire at the end of the request (which contains things such as response times, codes, etc.) did not. This means that for all you know, the request is on-going. There are a number of problems here, particularly if you're relying on monitoring tools to fire on errors. You could have an error which hangs for 10 minutes before it exits - how can you tell with the current implementation?

Using this module, you would simply swap out `plug Plug.Logger` with `pre_plug Plug.Logger`. Make sure to also `use PrePlug` before your usage of `pre_plug`, and voila, here is your output:

```elixir
00:09:31.481 [info]  GET /
00:09:31.487 [info]  Sent 400 in 6ms
```

Ok, perfect. Now we can see the response code as well as the execution time in our logs. This means we can error handle as necessary and do basically whatever we want.

## Warnings

I should point out that this does not mean that you should change all of your plugs to use `pre_plug`, only those which make sense to (e.g. logging, monitoring, other critical components).

I have been using this safely in a production app with no issue for a few months now, but it goes without saying to test your implementations thoroughly as this is pretty raw code.
