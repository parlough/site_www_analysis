#site_www_analysis

This repo hosts various [dart.dev](https://github.com/dart-lang/site-www) Git/GitHub analysis tools.

They are extremely ad-hoc, not supported, and more just posted on GitHub for easy personal tracking.

These tools expect some sort of GitHub authentication information as environmental variables,
checking in the following order:

```
GITHUB_ADMIN_TOKEN
GITHUB_DART_TOKEN
GITHUB_API_TOKEN
GITHUB_TOKEN
HOMEBREW_GITHUB_API_TOKEN
MACHINE_GITHUB_API_TOKEN
GITHUB_USERNAME and GITHUB_PASSWORD
```

Currently, there is only one tool:

## weekly_averages

It expects the authentication environment variables as indicated above as well as the amount of days to look back
in history as a positive integer.

```bash
$ dart <PATH TO DART FILE> <DAYS>
```

The following example, assuming you checked out this repository, you are in the root directory, and have
working environment variable set, will print out the average amount of issues and pull requests created in the
repository **within that time period**.

```bash
$ dart bin/weekly_averages.dart 365
```