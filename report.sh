#!/usr/bin/env bash
# report.sh: prints a short weather report from a forecast saved as JSON.
#
# Usage:   ./report.sh FORECAST_FILE
# Example: ./report.sh saved/forecast.json
#
# What it must do:
#   1. If there's no file FORECAST_FILE ($1), print a message that says so and stop
#      with exit code 1.
#   2. Print a first line with today's date as year-month-day:
#        Weather report for 2026-11-09
#   3. Print the forecast's first four periods, one line each: the name, a colon, the
#      temperature, its unit, a comma and the short forecast:
#        Today: 58 F, Mostly Sunny
#   4. Print a line for every period with a chance of rain of 50 or more:
#        Umbrella: Friday
#      or, when there are none, this one line:
#        Umbrella: not needed
#
# Read the forecast with jq. Each period is an item in .properties.periods, with
# .name, .temperature, .temperatureUnit, .shortForecast and
# .probabilityOfPrecipitation.value.
#
# Write your script under this line.
