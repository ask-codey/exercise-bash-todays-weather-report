#!/usr/bin/env bats
# Checks your two scripts, report.sh and fetch.sh, and the report you saved with them.
# Each script is tried for real on made-up files of its own, in a throwaway folder, so
# nothing in this folder is changed by the check, and no check needs the internet. The
# last check looks at this folder's reports/, after you've saved a report there.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
  dir="$BATS_TEST_TMPDIR/practice"
  mkdir -p "$dir"
}

# Runs one of your scripts with bash, so it works whether or not you've made it runnable.
run_script() {
  local script="$1"
  shift
  bash "$BATS_TEST_DIRNAME/$script" "$@"
}

# A script's lines without its comments, so the instructions at the top don't count as code.
code_of() {
  grep -v '^[[:space:]]*#' "$1"
}

# A made-up forecast, different from saved/forecast.json: six periods, three with a
# chance of rain of 50 or more (one of them after the first four, one exactly 50), and one
# with no chance given at all (null).
make_forecast() {
  printf '%s\n' '{ "properties": { "periods": [' \
    '{"name": "This Afternoon", "temperature": 71, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": 20}, "shortForecast": "Partly Sunny"},' \
    '{"name": "Tonight", "temperature": 55, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": 60}, "shortForecast": "Showers Likely"},' \
    '{"name": "Wednesday", "temperature": 64, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": 50}, "shortForecast": "Chance Showers"},' \
    '{"name": "Wednesday Night", "temperature": 49, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": 10}, "shortForecast": "Mostly Clear"},' \
    '{"name": "Thursday", "temperature": 68, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": 90}, "shortForecast": "Rain"},' \
    '{"name": "Thursday Night", "temperature": 51, "temperatureUnit": "F", "probabilityOfPrecipitation": {"value": null}, "shortForecast": "Cloudy"}' \
    '] } }' > "$dir/week.json"
}

# A made-up dry forecast in Celsius, with no chance of rain over 49.
make_dry() {
  printf '%s\n' '{ "properties": { "periods": [' \
    '{"name": "Today", "temperature": 21, "temperatureUnit": "C", "probabilityOfPrecipitation": {"value": 0}, "shortForecast": "Sunny"},' \
    '{"name": "Tonight", "temperature": 12, "temperatureUnit": "C", "probabilityOfPrecipitation": {"value": 5}, "shortForecast": "Clear"},' \
    '{"name": "Saturday", "temperature": 23, "temperatureUnit": "C", "probabilityOfPrecipitation": {"value": 49}, "shortForecast": "Partly Cloudy"},' \
    '{"name": "Saturday Night", "temperature": 14, "temperatureUnit": "C", "probabilityOfPrecipitation": {"value": 10}, "shortForecast": "Mostly Clear"},' \
    '{"name": "Sunday", "temperature": 24, "temperatureUnit": "C", "probabilityOfPrecipitation": {"value": 3}, "shortForecast": "Sunny"}' \
    '] } }' > "$dir/dry.json"
}

@test "the scripts, the saved forecast and jq are here" {
  for f in report.sh fetch.sh saved/forecast.json; do
    if [[ ! -f "$f" ]]; then
      echo "$f is missing. Download the exercise again to get it back."
      return 1
    fi
  done
  if ! command -v jq > /dev/null; then
    echo "jq isn't installed yet. Install it with: sudo apt install jq (or brew install jq on a Mac)."
    return 1
  fi
}

@test "1) report.sh starts with today's date" {
  make_forecast
  first="$(run_script report.sh "$dir/week.json" 2>/dev/null | head -n 1)"
  if [[ "$first" != "Weather report for $(date +%F)" ]]; then
    echo "The first line should be: Weather report for $(date +%F)"
    echo "It was: $first"
    echo "Let date make it, with the year, month and day as +%F gives them, inside \$( )."
    return 1
  fi
}

@test "2) report.sh prints the first four periods" {
  make_forecast
  got="$(run_script report.sh "$dir/week.json" 2>/dev/null | sed -n '2,5p')"
  want="$(printf '%s\n' 'This Afternoon: 71 F, Partly Sunny' 'Tonight: 55 F, Showers Likely' 'Wednesday: 64 F, Chance Showers' 'Wednesday Night: 49 F, Mostly Clear')"
  if [[ "$got" != "$want" ]]; then
    echo "For a forecast that starts with This Afternoon, lines 2 to 5 should be:"
    echo "$want"
    echo "They were:"
    echo "$got"
    echo "Build each line with jq -r and \\( ), and keep only the first four lines."
    return 1
  fi
  sixth="$(run_script report.sh "$dir/week.json" 2>/dev/null | sed -n '6p')"
  if [[ "$sixth" != Umbrella:* ]]; then
    echo "Line 6 should start the Umbrella lines, but it was: $sixth"
    echo "Print only the first four periods: head -n 4 keeps the first four lines."
    return 1
  fi
}

@test "3) report.sh uses the forecast's own unit" {
  make_dry
  second="$(run_script report.sh "$dir/dry.json" 2>/dev/null | sed -n '2p')"
  if [[ "$second" != "Today: 21 C, Sunny" ]]; then
    echo "For a forecast in Celsius, the second line should be: Today: 21 C, Sunny"
    echo "It was: $second"
    echo "Take the unit from .temperatureUnit; don't write F into the script."
    return 1
  fi
}

@test "4) report.sh lists every period with a chance of rain of 50 or more" {
  make_forecast
  got="$(run_script report.sh "$dir/week.json" 2>/dev/null | grep '^Umbrella' || true)"
  want="$(printf '%s\n' 'Umbrella: Tonight' 'Umbrella: Wednesday' 'Umbrella: Thursday')"
  if [[ "$got" != "$want" ]]; then
    echo "This forecast has a chance of rain of 50 or more on three periods, so the Umbrella lines should be:"
    echo "$want"
    echo "They were:"
    echo "${got:-(no Umbrella lines)}"
    echo "Look at every period, not only the first four, and keep the ones where select finds .probabilityOfPrecipitation.value >= 50."
    return 1
  fi
}

@test "5) report.sh says when no umbrella is needed" {
  make_dry
  got="$(run_script report.sh "$dir/dry.json" 2>/dev/null | grep '^Umbrella' || true)"
  if [[ "$got" != "Umbrella: not needed" ]]; then
    echo "With no chance of rain of 50 or more, the report should end with the one line: Umbrella: not needed"
    echo "It had: ${got:-(no Umbrella line)}"
    echo "Keep the rainy names in a variable, and test whether it's empty with [[ -z ... ]]."
    return 1
  fi
}

@test "6) report.sh stops with an error when the forecast file isn't there" {
  run run_script report.sh "$dir/no-such-forecast.json"
  if [[ "$status" -eq 0 ]]; then
    echo "Given a file that isn't there, report.sh should stop with exit code 1. It finished with 0."
    echo "Check first with [[ ! -f \$1 ]], print a message, and exit 1."
    return 1
  fi
}

@test "7) report.sh reads the forecast with jq" {
  if ! code_of report.sh | grep -Eq '(^|[^[:alnum:]_])jq([[:space:]]|$)'; then
    echo "report.sh doesn't use jq yet. Pick the values out of the JSON with jq -r."
    return 1
  fi
}

@test "8) fetch.sh saves what it downloads" {
  printf '{"properties": {"periods": []}}\n' > "$dir/fresh.json"
  run run_script fetch.sh "file://$dir/fresh.json" "$dir/saved.json"
  if [[ "$status" -ne 0 || ! -f "$dir/saved.json" ]]; then
    echo "fetch.sh didn't save the file it was given (exit code $status). Download \$1 with curl and save it with -o \"\$2\"."
    return 1
  fi
  if ! cmp -s "$dir/fresh.json" "$dir/saved.json"; then
    echo "The saved file isn't the same as the one fetch.sh downloaded."
    return 1
  fi
  if [[ "$output" != *"Saved $dir/saved.json"* ]]; then
    echo "When it works, fetch.sh should print: Saved FILE"
    echo "It printed: $output"
    return 1
  fi
}

@test "9) fetch.sh keeps the saved copy when the download fails" {
  printf 'yesterday'"'"'s forecast\n' > "$dir/saved.json"
  run run_script fetch.sh "https://forecast.invalid/today" "$dir/saved.json"
  if [[ "$status" -eq 0 ]]; then
    echo "Given an address that can't work, fetch.sh should stop with exit code 1. It finished with 0."
    echo "Use || or if, so a failed curl leads to a message and exit 1."
    return 1
  fi
  if [[ "$(cat "$dir/saved.json" 2>/dev/null)" != "yesterday's forecast" ]]; then
    echo "The download failed, but the saved file changed. Let curl write the file itself, with -o, so a failure leaves it alone."
    return 1
  fi
}

@test "10) fetch.sh uses curl -f and sends a User-Agent" {
  line="$(code_of fetch.sh | grep -E '(^|[^[:alnum:]_])curl[[:space:]]' | head -n 1)"
  if [[ -z "$line" ]]; then
    echo "fetch.sh doesn't run curl yet."
    return 1
  fi
  if ! grep -Eq -- '(^|[[:space:]])(-[a-zA-Z]*f[a-zA-Z]*|--fail)([[:space:]]|$)' <<< "$line"; then
    echo "The curl line has no -f yet. Without it, an error page such as 404 is saved as if it were the forecast."
    return 1
  fi
  if ! grep -Eq -- '(^|[[:space:]])(-[a-zA-Z]*A|--user-agent)([[:space:]]|$)|User-Agent' <<< "$line"; then
    echo "The curl line sends no User-Agent yet. Add -A with your script's name and your email address in quotes."
    return 1
  fi
}

@test "11) a dated report is saved in reports/" {
  shopt -s nullglob
  files=(reports/report-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].txt)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "There's no dated report in reports/ yet. When checks 1) to 7) pass, save one there, named report- and the date, such as reports/report-2026-11-09.txt. Let date make the name."
    return 1
  fi
  newest="${files[${#files[@]}-1]}"
  day="${newest#reports/report-}"
  day="${day%.txt}"
  if [[ "$(head -n 1 "$newest")" != "Weather report for $day" ]]; then
    echo "$newest should start with: Weather report for $day"
    echo "Make the report and its name on the same day, with the same date +%F."
    return 1
  fi
  if [[ "$(tail -n +2 "$newest")" != "$(run_script report.sh saved/forecast.json 2>/dev/null | tail -n +2)" ]]; then
    echo "$newest isn't the report for saved/forecast.json. Make it again from saved/forecast.json with report.sh."
    return 1
  fi
}
