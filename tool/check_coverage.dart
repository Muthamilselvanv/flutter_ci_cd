import 'dart:io';

void main(List<String> arguments) {
  final threshold = arguments.isEmpty ? 50.0 : double.parse(arguments.first);
  final report = File('coverage/lcov.info');

  if (!report.existsSync()) {
    stderr.writeln('Coverage report not found: ${report.path}');
    exitCode = 1;
    return;
  }

  var linesFound = 0;
  var linesHit = 0;

  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    }
  }

  if (linesFound == 0) {
    stderr.writeln('Coverage report contains no executable lines.');
    exitCode = 1;
    return;
  }

  final coverage = linesHit * 100 / linesFound;
  stdout.writeln(
    'Line coverage: ${coverage.toStringAsFixed(2)}% '
    '($linesHit/$linesFound), required: ${threshold.toStringAsFixed(2)}%',
  );

  if (coverage < threshold) {
    stderr.writeln('Coverage quality gate failed.');
    exitCode = 1;
  }
}
