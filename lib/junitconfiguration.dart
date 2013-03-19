// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library junitconfiguration;

import 'dart:io';
import 'package:meta/meta.dart';
import 'package:unittest/unittest.dart';

/**
 * A test configuration that emits JUnit compatible XML output.
 */
class JUnitConfiguration extends Configuration {

  /**
   * Install this configuration with the testing framework.
   */
  static Configuration install([IOSink output]) {
    return configure(new JUnitConfiguration(output));
  }

  /**
   * Creates a new configuration instance with an optional output sink.
   */
  factory JUnitConfiguration([IOSink output]) {
    return new JUnitConfiguration._internal(output != null ? output : stdout);
  }

  final IOSink _output;

  JUnitConfiguration._internal(this._output);

  String get name => 'JUnit Test Configuration';

  @override
  void onInit() {
    // nothing to be done
  }

  @override
  void onSummary(int passed, int failed, int errors, List<TestCase> results, String uncaughtError) {
    var totalTime = 0;
    for (var testcase in results) {
      totalTime += testcase.runningTime.inMilliseconds;
    }
    _output.writeln('<?xml version="1.0" encoding="UTF-8" ?>');
    _output.writeln('<testsuite name="All tests" tests="${results.length}" failures="$failed" errors="$errors" time="${totalTime / 1000.0}" timestamp="${new DateTime.now()}">');
    for (var testcase in results) {
      _output.writeln('  <testcase id="${testcase.id}" name="${_xml(testcase.description)}" time="${testcase.runningTime.inMilliseconds / 1000.0}">');
      if (testcase.result == 'fail') {
        _output.writeln('    <failure>${_xml(testcase.message)}</failure>');
      } else if (testcase.result == 'error') {
        _output.writeln('    <error>${_xml(testcase.message)}</error>');
      }
      if (testcase.stackTrace != null && testcase.stackTrace != '') {
        _output.writeln('    <system-err>${_xml(testcase.stackTrace)}</system-err>');
      }
      _output.writeln('  </testcase>');
    }
    if (uncaughtError != null && uncaughtError != '') {
      _output.writeln('  <system-err>${_xml(uncaughtError)}</system-err>');
    }
    _output.writeln('</testsuite>');
  }

  @override
  void onDone(bool success) {
    // nothing to be done
  }

  String _xml(String string) {
    return string
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

}