#!/usr/bin/env bash
# fetch.sh: downloads a forecast, or any file, from a web address and saves it.
#
# Usage:   ./fetch.sh ADDRESS FILE
# Example: ./fetch.sh 'https://api.weather.gov/gridpoints/OKX/34,45/forecast' saved/forecast.json
#
# What it must do:
#   1. Download ADDRESS ($1) with curl, and save it as FILE ($2).
#   2. Send a User-Agent with your script's name and your email address, as weather.gov
#      asks, such as:  todays-weather-report (you@example.com)
#   3. Fail on an error answer, such as 404, instead of saving the error page.
#   4. When it works, print:  Saved FILE   (for example:  Saved saved/forecast.json)
#   5. When it fails, print a message that says so, leave FILE exactly as it was,
#      and stop with exit code 1.
#
# Write your script under this line.
