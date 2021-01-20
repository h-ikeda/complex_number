defmodule ComplexNumber do
  @moduledoc """
  Functions for complex number operations.
  """
  @pi :math.pi()
  @type t :: number | %ComplexNumber{radius: number, theta: number}
  defstruct [:radius, :theta]

  @doc """
  Checks if the argument is a complex (including real) number or not.

      iex> ComplexNumber.is_complex_number(6.85)
      true

      iex> ComplexNumber.is_complex_number(-3)
      true

      iex> ComplexNumber.is_complex_number(ComplexNumber.new(3.5, -1))
      true

      iex> ComplexNumber.is_complex_number(:atom)
      false

      iex> ComplexNumber.is_complex_number("binary")
      false
  """
  if Version.match?(System.version(), "< 1.11.0") do
    defmacrop is_struct(term, _) do
      case __CALLER__.context do
        nil ->
          quote do
            case unquote(term) do
              %{__struct__: ComplexNumber} -> true
              _ -> false
            end
          end

        :match ->
          raise ArgumentError,
                "invalid expression in match, is_struct/2 is not allowed in patterns such as " <>
                  "function clauses, case clauses or on the left side of the = operator"

        :guard ->
          quote do
            is_map(unquote(term)) and
              :erlang.is_map_key(:__struct__, unquote(term)) and
              :erlang.map_get(:__struct__, unquote(term)) == ComplexNumber
          end
      end
    end
  end

  defguard is_complex_number(number) when is_number(number) or is_struct(number, ComplexNumber)

  @doc """
  Creates a new complex number from a real part and an imaginary part.

  If the imaginary part is zero, it just returns a real number.

      iex> ComplexNumber.new(3, 4)
      %ComplexNumber{radius: 5.0, theta: 0.9272952180016122}

      iex> ComplexNumber.new(-3, 4)
      %ComplexNumber{radius: 5.0, theta: 2.214297435588181}

      iex> ComplexNumber.new(3, 0)
      3
  """
  @spec new(number, number) :: t
  def new(real, imaginary) when is_number(real) and imaginary == 0, do: real

  def new(real, imaginary) when is_number(real) and is_number(imaginary) do
    %ComplexNumber{
      radius: :math.sqrt(real * real + imaginary * imaginary),
      theta: :math.atan2(imaginary, real)
    }
  end

  @doc """
  Returns the real part of the given complex number.

      iex> ComplexNumber.real(ComplexNumber.new(6.2, 3))
      6.2

      iex> ComplexNumber.real(4)
      4
  """
  @spec real(t) :: number
  def real(number) when is_number(number), do: number
  def real(%ComplexNumber{radius: radius, theta: theta}), do: radius * :math.cos(theta)

  @doc """
  Returns the imaginary part of the given complex number.

      iex> ComplexNumber.imaginary(ComplexNumber.new(6.2, 3))
      3.0

      iex> ComplexNumber.imaginary(4)
      0
  """
  @spec imaginary(t) :: number
  def imaginary(number) when is_number(number), do: 0
  def imaginary(%ComplexNumber{radius: radius, theta: theta}), do: radius * :math.sin(theta)

  @doc """
  Returns the absolute value of the given complex number.

      iex> ComplexNumber.abs(ComplexNumber.new(4, -3))
      5.0

      iex> ComplexNumber.abs(4.2)
      4.2
  """
  @spec abs(t) :: number
  def abs(number) when is_number(number), do: Kernel.abs(number)
  def abs(%ComplexNumber{radius: radius}), do: Kernel.abs(radius)

  @doc """
  Negates a complex number.

      iex> ComplexNumber.negate(ComplexNumber.new(4, -3))
      %ComplexNumber{radius: -5.0, theta: -0.6435011087932844}

      iex> ComplexNumber.negate(4.2)
      -4.2
  """
  @spec negate(t) :: t
  def negate(number) when is_number(number), do: -number
  def negate(%ComplexNumber{radius: radius} = number), do: %{number | radius: -radius}

  @doc """
  Adds two complex numbers.

      iex> ComplexNumber.add(ComplexNumber.new(0.5, 2.5), ComplexNumber.new(2.5, 1.5))
      %ComplexNumber{radius: 5.0, theta: 0.9272952180016122}

      iex> ComplexNumber.add(ComplexNumber.new(0.5, 4), 2.5)
      %ComplexNumber{radius: 5.0, theta: 0.9272952180016121}

      iex> ComplexNumber.add(2.5, ComplexNumber.new(0.5, 4))
      %ComplexNumber{radius: 5.0, theta: 0.9272952180016121}

      iex> ComplexNumber.add(3.5, 2.5)
      6.0
  """
  @spec add(t, t) :: t
  def add(number1, number2) when is_number(number1) and is_number(number2), do: number1 + number2

  def add(number, %ComplexNumber{radius: radius, theta: theta}) when is_number(number) do
    new(radius * :math.cos(theta) + number, radius * :math.sin(theta))
  end

  def add(%ComplexNumber{radius: radius, theta: theta}, number) when is_number(number) do
    new(radius * :math.cos(theta) + number, radius * :math.sin(theta))
  end

  def add(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      ) do
    new(
      radius1 * :math.cos(theta1) + radius2 * :math.cos(theta2),
      radius1 * :math.sin(theta1) + radius2 * :math.sin(theta2)
    )
  end

  @doc """
  Subtracts a complex number from another one.

      iex> ComplexNumber.subtract(ComplexNumber.new(0.5, 2.5), ComplexNumber.new(2.5, 1.5))
      %ComplexNumber{radius: 2.2360679774997894, theta: 2.6779450445889874}

      iex> ComplexNumber.subtract(ComplexNumber.new(0.5, 4), 2.5)
      %ComplexNumber{radius: 4.472135954999579, theta: 2.0344439357957027}

      iex> ComplexNumber.subtract(2.5, ComplexNumber.new(0.5, 4))
      %ComplexNumber{radius: 4.472135954999579, theta: 1.1071487177940906}

      iex> ComplexNumber.subtract(3.5, 2.5)
      1.0
  """
  @spec subtract(t, t) :: t
  def subtract(number1, number2) when is_number(number1) and is_number(number2) do
    number1 - number2
  end

  def subtract(number, %ComplexNumber{radius: radius, theta: theta}) when is_number(number) do
    new(number - radius * :math.cos(theta), radius * :math.sin(theta))
  end

  def subtract(%ComplexNumber{radius: radius, theta: theta}, number) when is_number(number) do
    new(radius * :math.cos(theta) - number, radius * :math.sin(theta))
  end

  def subtract(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      ) do
    new(
      radius1 * :math.cos(theta1) - radius2 * :math.cos(theta2),
      radius1 * :math.sin(theta1) - radius2 * :math.sin(theta2)
    )
  end

  @doc """
  Makes a product of two complex numbers.

      iex> ComplexNumber.multiply(ComplexNumber.new(2, -3), ComplexNumber.new(-3, 0.5))
      %ComplexNumber{radius: 10.965856099730653, theta: 1.993650252927837}

      iex> ComplexNumber.multiply(ComplexNumber.new(2, -3), ComplexNumber.new(3, 4.5))
      19.5

      iex> ComplexNumber.multiply(ComplexNumber.new(2, 3), ComplexNumber.new(-3, 4.5))
      -19.5

      iex> ComplexNumber.multiply(2.5, ComplexNumber.new(3, -0.5))
      %ComplexNumber{radius: 7.603453162872774, theta: -0.16514867741462683}

      iex> ComplexNumber.multiply(ComplexNumber.new(3, -0.5), 2.5)
      %ComplexNumber{radius: 7.603453162872774, theta: -0.16514867741462683}

      iex> ComplexNumber.multiply(4, 2.5)
      10.0
  """
  @spec multiply(t, t) :: t
  def multiply(number1, number2) when is_number(number1) and is_number(number2) do
    number1 * number2
  end

  def multiply(number1, %ComplexNumber{radius: radius} = number2) when is_number(number1) do
    %{number2 | radius: radius * number1}
  end

  def multiply(%ComplexNumber{radius: radius} = number2, number1) when is_number(number1) do
    %{number2 | radius: radius * number1}
  end

  def multiply(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      )
      when trunc((theta1 + theta2) * 0.5 / @pi) == (theta1 + theta2) * 0.5 / @pi do
    radius1 * radius2
  end

  def multiply(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      )
      when trunc((theta1 + theta2) / @pi) == (theta1 + theta2) / @pi do
    -radius1 * radius2
  end

  def multiply(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      ) do
    %ComplexNumber{radius: radius1 * radius2, theta: theta1 + theta2}
  end

  @doc """
  Divides a complex number by another one.

      iex> ComplexNumber.divide(ComplexNumber.new(3, -0.5), ComplexNumber.new(2, 1.5))
      %ComplexNumber{radius: 1.2165525060596438, theta: -0.8086497862079112}

      iex> ComplexNumber.divide(ComplexNumber.new(3, -0.75), ComplexNumber.new(2, -0.5))
      1.5

      iex> ComplexNumber.divide(ComplexNumber.new(-3, -0.75), ComplexNumber.new(2, 0.5))
      -1.5

      iex> ComplexNumber.divide(3, ComplexNumber.new(2, 1.5))
      %ComplexNumber{radius: 1.2, theta: -0.6435011087932844}

      iex> ComplexNumber.divide(ComplexNumber.new(3, -0.5), 2)
      %ComplexNumber{radius: 1.5206906325745548, theta: -0.16514867741462683}

      iex> ComplexNumber.divide(3, 2)
      1.5
  """
  @spec divide(t, t) :: t
  def divide(number1, number2) when is_number(number1) and is_number(number2) do
    number1 / number2
  end

  def divide(number, %ComplexNumber{radius: radius, theta: theta}) when is_number(number) do
    %ComplexNumber{radius: number / radius, theta: -theta}
  end

  def divide(%ComplexNumber{radius: radius} = number1, number2) when is_number(number2) do
    %{number1 | radius: radius / number2}
  end

  def divide(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      )
      when trunc((theta1 - theta2) * 0.5 / @pi) == (theta1 - theta2) * 0.5 / @pi do
    radius1 / radius2
  end

  def divide(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      )
      when trunc((theta1 - theta2) / @pi) == (theta1 - theta2) / @pi do
    -radius1 / radius2
  end

  def divide(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      ) do
    %ComplexNumber{radius: radius1 / radius2, theta: theta1 - theta2}
  end

  @doc """
  Returns a multivalued function representing the given base taken to the power of the given
  exponent.

      iex> ComplexNumber.pow(ComplexNumber.new(6, 1.5), ComplexNumber.new(-4, -0.4)).(0)
      %ComplexNumber{radius: 0.0007538662030076445, theta: -1.708743364561965}

      iex> ComplexNumber.pow(6.5, ComplexNumber.new(-4, -0.4)).(0)
      %ComplexNumber{radius: 0.0005602044746332418, theta: -0.7487208707606361}

      iex> ComplexNumber.pow(ComplexNumber.new(6, 1.5), -4.4).(0)
      %ComplexNumber{radius: 0.0003297697637520032, theta: -1.0779061177582023}

      iex> ComplexNumber.pow(6.5, -4.4).(0)
      0.0002649605586423526

      iex> ComplexNumber.pow(6.5, -4.4).(1)
      %ComplexNumber{radius: 0.00026496055864235266, theta: -2.5132741228718367}

      iex> ComplexNumber.pow(6.5, 0.5).(1)
      -2.5495097567963922
  """
  @spec pow(t, t) :: (integer -> t)
  def pow(number1, number2) when is_number(number1) and is_integer(number2) do
    fn n when is_integer(n) -> :math.pow(number1, number2) end
  end

  def pow(number1, number2) when is_number(number1) and number1 < 0 and is_float(number2) do
    fn
      n when is_integer(n) and trunc((n + 0.5) * number2) == (n + 0.5) * number2 ->
        :math.pow(number1, number2)

      n when is_integer(n) and trunc((n * 2 + 1) * number2) == (n * 2 + 1) * number2 ->
        -:math.pow(number1, number2)

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(number2 * :math.log(-number1)),
          theta: ((n + 0.5) * number2 - trunc((n + 0.5) * number2)) * 2 * @pi
        }
    end
  end

  def pow(number1, number2) when is_number(number1) and is_float(number2) do
    fn
      n when is_integer(n) and trunc(n * number2) == n * number2 ->
        :math.pow(number1, number2)

      n when is_integer(n) and trunc(n * 2 * number2) == n * 2 * number2 ->
        -:math.pow(number1, number2)

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(number2 * :math.log(number1)),
          theta: (n * number2 - trunc(n * number2)) * 2 * @pi
        }
    end
  end

  def pow(number, %ComplexNumber{radius: radius, theta: theta})
      when is_number(number) and number < 0 do
    x = radius * :math.cos(theta)
    y = radius * :math.sin(theta)
    log = :math.log(-number)

    fn
      n
      when is_integer(n) and
             trunc((n + 0.5) * x + y * log * 0.5 / @pi) == (n + 0.5) * x + y * log * 0.5 / @pi ->
        :math.exp(x * log - (2 * n + 1) * @pi * y)

      n
      when is_integer(n) and
             trunc((2 * n + 1) * x + y * log / @pi) == (2 * n + 1) * x + y * log / @pi ->
        -:math.exp(x * log - (2 * n + 1) * @pi * y)

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(x * log - (2 * n + 1) * @pi * y),
          theta: (2 * n + 1) * @pi * x + y * log
        }
    end
  end

  def pow(number, %ComplexNumber{radius: radius, theta: theta}) when is_number(number) do
    x = radius * :math.cos(theta)
    y = radius * :math.sin(theta)
    log = :math.log(number)

    fn
      n
      when is_integer(n) and trunc(n * x + y * log * 0.5 / @pi) == n * x + y * log * 0.5 / @pi ->
        :math.exp(x * log - 2 * @pi * n * y)

      n when is_integer(n) and trunc(2 * n * x + y * log / @pi) == 2 * n * x + y * log / @pi ->
        -:math.exp(x * log - 2 * @pi * n * y)

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(x * log - 2 * @pi * n * y),
          theta: 2 * @pi * n * x + y * log
        }
    end
  end

  def pow(%ComplexNumber{radius: radius, theta: theta}, number)
      when is_number(number) and radius < 0 do
    fn
      n
      when is_integer(n) and
             trunc(((theta / @pi + 1) * 0.5 + n) * number) ==
               ((theta / @pi + 1) * 0.5 + n) * number ->
        :math.pow(-radius, number)

      n
      when is_integer(n) and
             trunc((theta / @pi + n * 2 + 1) * number) == (theta / @pi + n * 2 + 1) * number ->
        -:math.pow(-radius, number)

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.pow(-radius, number),
          theta: (theta + (2 * n + 1) * @pi) * number
        }
    end
  end

  def pow(%ComplexNumber{radius: radius, theta: theta}, number) when is_number(number) do
    fn
      n
      when is_integer(n) and
             trunc((theta * 0.5 / @pi + n) * number) == (theta * 0.5 / @pi + n) * number ->
        :math.pow(radius, number)

      n
      when is_integer(n) and
             trunc((theta / @pi + n * 2) * number) == (theta / @pi + n * 2) * number ->
        -:math.pow(radius, number)

      n when is_integer(n) ->
        %ComplexNumber{radius: :math.pow(radius, number), theta: (theta + 2 * n * @pi) * number}
    end
  end

  def pow(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      )
      when radius1 < 0 do
    log_r = :math.log(-radius1)
    x2 = radius2 * :math.cos(theta2)
    y2 = radius2 * :math.sin(theta2)
    p = x2 * theta1 + y2 * log_r

    fn
      n
      when is_integer(n) and
             trunc((n + 0.5) * x2 + p * 0.5 / @pi) == (n + 0.5) * x2 + p * 0.5 / @pi ->
        :math.exp(x2 * log_r - y2 * (theta1 + 2 * n * @pi))

      n when is_integer(n) and trunc((n * 2 + 1) * x2 + p / @pi) == (n * 2 + 1) * x2 + p / @pi ->
        -:math.exp(x2 * log_r - y2 * (theta1 + 2 * n * @pi))

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(x2 * log_r - y2 * ((2 * n + 1) * @pi + theta1)),
          theta: (2 * n + 1) * @pi * x2 + p
        }
    end
  end

  def pow(
        %ComplexNumber{radius: radius1, theta: theta1},
        %ComplexNumber{radius: radius2, theta: theta2}
      ) do
    log_r = :math.log(radius1)
    x2 = radius2 * :math.cos(theta2)
    y2 = radius2 * :math.sin(theta2)
    p = x2 * theta1 + y2 * log_r

    fn
      n when is_integer(n) and trunc(n * x2 + p * 0.5 / @pi) == n * x2 + p * 0.5 / @pi ->
        :math.exp(x2 * log_r - y2 * (theta1 + 2 * n * @pi))

      n when is_integer(n) and trunc(n * x2 * 2 + p / @pi) == n * x2 * 2 + p / @pi ->
        -:math.exp(x2 * log_r - y2 * (theta1 + 2 * n * @pi))

      n when is_integer(n) ->
        %ComplexNumber{
          radius: :math.exp(x2 * log_r - y2 * (2 * n * @pi + theta1)),
          theta: 2 * n * @pi * x2 + p
        }
    end
  end

  @doc """
  Returns the cosine of a complex number.

      iex> ComplexNumber.cos(2.1)
      -0.5048461045998576

      iex> ComplexNumber.cos(ComplexNumber.new(3, -0.5))
      %ComplexNumber{radius: 1.1187606807234534, theta: 3.075814483757404}
  """
  @spec cos(t) :: t
  def cos(number) when is_number(number), do: :math.cos(number)

  def cos(%ComplexNumber{radius: radius, theta: theta}) do
    x = radius * :math.cos(theta)
    y = radius * :math.sin(theta)
    new(:math.cos(x) * :math.cosh(y), -:math.sin(x) * :math.sinh(y))
  end

  @doc """
  Returns the sine of a complex number.

      iex> ComplexNumber.sin(2.1)
      0.8632093666488737

      iex> ComplexNumber.sin(ComplexNumber.new(3, -0.5))
      %ComplexNumber{radius: 0.5398658852737769, theta: 1.2715925251688622}
  """
  @spec sin(t) :: t
  def sin(number) when is_number(number), do: :math.sin(number)

  def sin(%ComplexNumber{radius: radius, theta: theta}) do
    x = radius * :math.cos(theta)
    y = radius * :math.sin(theta)
    new(:math.sin(x) * :math.cosh(y), :math.cos(x) * :math.sinh(y))
  end

  @doc """
  Returns the tangent of a complex number.

      iex> ComplexNumber.tan(2.1)
      -1.7098465429045073

      iex> ComplexNumber.tan(ComplexNumber.new(3, -0.5))
      %ComplexNumber{radius: 0.482557078181072, theta: -1.804221958588542}
  """
  @spec tan(t) :: t
  def tan(number) when is_number(number), do: :math.tan(number)

  def tan(%ComplexNumber{radius: radius, theta: theta}) do
    x = radius * :math.cos(theta)
    y = radius * :math.sin(theta)
    denominator = :math.cos(x * 2) + :math.cosh(y * 2)
    new(:math.sin(x * 2) / denominator, :math.sinh(y * 2) / denominator)
  end
end
