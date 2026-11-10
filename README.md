# Exercise: Today's Weather Report

Exercise code for the lesson **Exercise: Today's Weather Report** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

Every morning you'd like one short report: today's date, the weather for the next two days, and whether to pack an umbrella this week. Write two small tools, `report.sh`, which turns a saved forecast into that report, and `fetch.sh`, which downloads a fresh forecast without ever losing the saved one. Then save today's report under today's date, and let a check script tell you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows), **jq**, which reads the forecast, and **bats**, the tool that runs the check. `curl` is already there. If `jq --version` or `bats --version` doesn't print a version yet, install them:

```bash
sudo apt install jq bats       # Ubuntu, and Ubuntu in WSL
brew install jq bats-core      # a Mac, with Homebrew
```

**On Windows, unzip or clone this folder inside Ubuntu**, in your Linux home folder (for example `~/terminal-practice/`), not in a Windows folder under `/mnt/c`, so `chmod` works on the scripts.

## What's here

- `report.sh`: prints a short weather report from a saved forecast. For you to finish.
- `fetch.sh`: downloads a file from a web address and saves it. For you to finish.
- `saved/forecast.json`: a real forecast for New York's Central Park from the US National Weather Service (`api.weather.gov`, public domain), cut down to the parts the report needs. Ready to use: your `report.sh` reads it.
- `reports/`: where your dated reports go.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `check.bats` in it), make the two scripts runnable, and open the first one:

```bash
chmod +x report.sh fetch.sh
nano report.sh
```

The comment at the top of each script says exactly what it must do. Write your lines under the last comment, save with Ctrl+O and Enter, and quit with Ctrl+X. Try each script as you go: `./report.sh saved/forecast.json`.

The jobs:

1. **`report.sh FORECAST_FILE`** checks that the file is there (if not, it says so and stops with exit code 1), then prints `Weather report for` and today's date as year-month-day; one line for each of the forecast's first four periods, such as `Today: 58 F, Mostly Sunny`; and `Umbrella: Friday` for every period with a chance of rain of 50 or more, or the one line `Umbrella: not needed` when there's none.
2. **`fetch.sh ADDRESS FILE`** downloads the address with `curl` and saves it as the file, sending a User-Agent with your script's name and your email address. It fails on an error answer such as 404, instead of saving the error page. When it works it prints `Saved FILE`; when it fails it says so, leaves the file exactly as it was, and stops with exit code 1.
3. **Save today's report.** When the checks for `report.sh` pass, save its report for `saved/forecast.json` in `reports/`, named `report-` and today's date, such as `reports/report-2026-11-09.txt`. Let `date` make the name.

**With the internet (optional):** when `fetch.sh` works, get a fresh forecast before you save your report:

```bash
./fetch.sh 'https://api.weather.gov/gridpoints/OKX/34,45/forecast' saved/forecast.json
```

The fresh copy has more in it than the saved one, and your report reads it the same way. Asking for a place that isn't covered, or an address with a typo, fails, and the saved forecast stays as it was.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its checks into a ✓. A failing check's message says what to look at. The check tries each script on made-up forecasts and files of its own, in a throwaway folder, with no internet needed; only the last check looks at this folder's `reports/`.

## The rules

- `report.sh` reads the forecast with `jq`, and works on the file it's given as `$1`, not on a name written into the script.
- The temperature's unit comes from the forecast (`F` here, `C` in a forecast asked for with `?units=si`).
- `fetch.sh` uses `curl` with `-f`, and lets `curl` write the file with `-o`.
- Print the lines exactly as shown: `Weather report for 2026-11-09`, `Today: 58 F, Mostly Sunny`, `Umbrella: Friday`, `Umbrella: not needed`, `Saved saved/forecast.json`.

## Tips

- Every period is an item in `.properties.periods`, with `.name`, `.temperature`, `.temperatureUnit`, `.shortForecast` and `.probabilityOfPrecipitation.value`.
- `jq -r` prints text without quotes, and `"\(.name): \(.temperature)"` builds a line from an item's values.
- `head -n 4` keeps the first four lines of whatever is piped into it.
- `select(... >= 50)` keeps only the periods whose test is true. Keep the names in a variable with `$( )`, then test whether it's empty with `[[ -z $rainy ]]`.
- `$(date +%F)` is today's date as year-month-day, in a line of text or in a file name.
- `curl -fsS` fails on an error answer, stays quiet when it works, and still shows the error when it fails. `-A '...'` sets the User-Agent.
- `if curl ...; then ...; else ...; fi` runs one part when curl works and the other when it fails.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
