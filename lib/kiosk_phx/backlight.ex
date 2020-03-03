defmodule KioskPhx.Backlight do
  use GenServer

  @brightness_file "/sys/class/backlight/rpi_backlight/brightness"

  # Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # GenServer Callbacks

  def init(_opts) do
    {:ok, 255}
  end

  def handle_call(:brightness, _from, brightness) do
    {:reply, brightness, brightness}
  end

  def handle_call({:brightness, value}, _from, _brightness) do
    value = value |> round()
    if File.exists?(@brightness_file) do
      File.write(@brightness_file, to_string(value))
    end

    {:reply, value, value}
  end

  def set_brightness(value) when value >= 0 and value <= 255 do
    GenServer.call(__MODULE__, {:brightness, value})
  end

  def set_brightness(_value) do
    {:error, "Value must be >= 0 and <= 255"}
  end

  def brightness(value), do: set_brightness(value)

  def brightness() do
    GenServer.call(__MODULE__, :brightness)
  end
end
