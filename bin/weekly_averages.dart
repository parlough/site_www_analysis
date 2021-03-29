import 'dart:io';

import 'package:github/github.dart';
import 'package:intl/intl.dart';

void main(final List<String> arguments) async {
  if (arguments.isEmpty) {
    throw 'You must specify how many days to look back.';
  }

  final arg = arguments[0];
  final days = int.tryParse(arg);
  if (days == null || days < 0) {
    throw 'The amount of days you specify must be a positive integer.';
  }

  final today = DateTime.now();
  final startDate = today.subtract(Duration(days: days));

  final github = GitHub(auth: findAuthenticationFromEnvironment());
  final slug = RepositorySlug('dart-lang', 'site-www');

  final issues = await github.issues
      .listByRepo(slug,
          state: 'all', since: startDate, sort: 'created', direction: 'desc')
      .toList();

  const sevenDays = Duration(days: 7);
  var afterDate = today.subtract(sevenDays);

  // Keep track of the issues and pull requests, in case we want to access
  // more information about them than just the count.
  final weeklyIssues = <DateTime, List<Issue>>{afterDate: []};
  final weeklyPullRequests = <DateTime, List<IssuePullRequest>>{afterDate: []};

  for (final issue in issues) {
    final createdAt = issue.createdAt;

    if (createdAt == null) {
      return;
    }

    // Since the since parameter to the API seems to apply to last updated
    // rather than created, stop once we hit the first one created before the
    // specified date.
    if (createdAt.isBefore(startDate)) {
      break;
    }

    if (createdAt.isAfter(afterDate)) {
      afterDate = afterDate.subtract(sevenDays);
    }

    final pullRequest = issue.pullRequest;

    // The Github v3 issues API includes pull requests as issues, we can
    // differentiate between the two if Issue#pullRequest is `null` or not.
    if (pullRequest == null) {
      final issuesFromWeek = weeklyIssues[afterDate];
      if (issuesFromWeek == null) {
        weeklyIssues[afterDate] = [issue];
      } else {
        issuesFromWeek.add(issue);
      }
    } else {
      final pullRequestsFromWeek = weeklyPullRequests[afterDate];
      if (pullRequestsFromWeek == null) {
        weeklyPullRequests[afterDate] = [pullRequest];
      } else {
        pullRequestsFromWeek.add(pullRequest);
      }
    }
  }

  // Calculate the total amount of issues.
  final issueCount = weeklyIssues.values
      .map((e) => e.length)
      .reduce((value, element) => value + element);

  final formattedStartDate = DateFormat.yMd().format(startDate);
  final weeks = days / 7;

  final decimalFormatter = NumberFormat.decimalPattern();

  print('Total issues since $formattedStartDate: $issueCount');
  print(
      'Average issues created per week: ${decimalFormatter.format(issueCount / weeks)}');

  // Calculate the total amount of pull requests.
  final pullRequestCount = weeklyPullRequests.values
      .map((e) => e.length)
      .reduce((value, element) => value + element);

  print('');

  print('Total pull requests since $formattedStartDate: $pullRequestCount');
  print(
      'Average pull requests opened per week: ${decimalFormatter.format(pullRequestCount / weeks)}');

  exit(0);
}
