defmodule OatFirst.Uptime do
  def seconds do
    ms = :erlang.statistics(:wall_clock) |> elem(0)
    div(ms, 1_000)
  end

  def human_readable do
    format_duration(seconds())
  end

  def format_duration(seconds) when seconds < 60 do
    "#{pluralize("second", seconds)}"
  end

  def format_duration(seconds) do
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    cond do
      minutes < 60 ->
        compose("minute", minutes, "second", seconds)

      true ->
        hours = div(minutes, 60)
        minutes = rem(minutes, 60)

        cond do
          hours < 24 ->
            compose("hour", hours, "minute", minutes)

          true ->
            days = div(hours, 24)
            hours = rem(hours, 24)

            cond do
              days < 7 ->
                compose("day", days, "hour", hours)

              true ->
                weeks = div(days, 7)
                days = rem(days, 7)

                compose("week", weeks, "day", days)
            end
        end
    end
  end

  defp pluralize(word, count) when count != 1, do: "#{count} #{word}s"
  defp pluralize(word, count) when count == 1, do: "#{count} #{word}"

  defp compose(unit1, count1, _unit2, count2) when count2 == 0 do
    "#{pluralize(unit1, count1)}"
  end

  defp compose(unit1, count1, unit2, count2) when count2 > 0 do
    "#{pluralize(unit1, count1)}, #{pluralize(unit2, count2)}"
  end

  def formatted do
    total_seconds = seconds()

    days = div(total_seconds, 86_400)
    hours = div(rem(total_seconds, 86_400), 3_600)
    minutes = div(rem(total_seconds, 3_600), 60)
    seconds = rem(total_seconds, 60)

    "#{days}d #{hours}h #{minutes}m #{seconds}s"
  end
end
