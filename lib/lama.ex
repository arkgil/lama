defmodule Lama do
  @moduledoc """
  Common operations on higher order functions
  """

  @doc """
  Curries function and applies one or more arguments

  It will raise if number of arguments passed is more
  than function arity.

  ## Examples

      iex> a = fn x, y -> x + y end
      iex> b = Lama.curry a, 1
      iex> b.(1)
      2

      iex> a = fn x, y -> x + y end
      iex> Lama.curry a, [1, 2]
      3
  """
  def curry(fun, args) when is_function(fun) and is_list(args) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    args_len = length(args)
    cond do
      arity == args_len ->
        apply(fun, args)
      arity > args_len ->
        fn arg ->
          curry(fun, args ++ [arg])
        end
      true ->
        raise ArgumentError, "curry/2 can not recieve more arguments " <>
          "than function arity"
    end
  end
  def curry(fun, arg) when is_function(fun) do
    curry(fun, [arg])
  end

  @doc """
  Curries function

  It will raise if 0 arity function is given, and return
  the function unchanged if it has arity of 1.

  ## Examples

      iex> a = fn x, y -> x + y end
      iex> b = Lama.curry a
      iex> c = b.(1)
      iex> c.(3)
      4
  """
  def curry(fun) when is_function(fun, 0) do
    raise ArgumentError, "cannot curry 0 arity function"
  end
  def curry(fun) when is_function(fun, 1), do: fun
  def curry(fun) when is_function(fun) do
    fn arg ->
      curry(fun, [arg])
    end
  end

  @doc """
  Performs function composition

  Calling compose(f, g).(x) is equivalent to calling
  f.(g.(x)), or more Elixiry x |> g.() |> f.().

  It will raise if given functions have arity different than 0.

  ## Examples

      iex> f = fn x -> x + 2 end
      iex> g = fn x -> x * 3 end
      iex> h = Lama.compose(f, g)
      iex> h.(2)
      8
  """
  def compose(f, g) when is_function(f, 1) and is_function(g, 1) do
    fn x ->
      x |> g.() |> f.()
    end
  end
  def compose(_, _) do
    raise "compose/2 accepts only 1 arity functions as arguments"
  end

  @doc """
  Equivalent to `compose/2`, with the same order of
  arguments

  ## Examples

      iex> import Lama
      iex> f = fn x -> x + 2 end
      iex> g = fn x -> x * 3 end
      iex> (f <~ g).(2)
      8
  """
  def f <~ g, do: compose(f, g)

  @doc """
  Equivalent to `compose/2`, with reversed order of arguments

  ## Examples

      iex> import Lama
      iex> f = fn x -> x + 2 end
      iex> g = fn x -> x * 3 end
      iex> (g ~> f).(2)
      8
  """
  def g ~> f, do: compose(f, g)
end
