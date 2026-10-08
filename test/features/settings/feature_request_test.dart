import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/settings/screens/settings_screen.dart';

void main() {
  test('GitHub link opens the feature-request form with the version', () {
    final url = featureRequestGithubUrl('2.0.1 (30)');
    expect(url.host, 'github.com');
    expect(url.path, '/giladtamam/zigdash/issues/new');
    expect(url.queryParameters['template'], 'feature_request.yml');
    expect(url.queryParameters['version'], '2.0.1 (30)');
  });

  test('problem report opens the bug-report form with the version', () {
    final url = problemReportGithubUrl('2.0.1 (30)');
    expect(url.path, '/giladtamam/zigdash/issues/new');
    expect(url.queryParameters['template'], 'bug_report.yml');
    expect(url.queryParameters['version'], '2.0.1 (30)');
  });

  test('email goes to the developer with subject, prompt and version', () {
    final url = feedbackMailUrl(
      version: '2.0.1 (30)',
      subject: 'ZigDash feature request',
      prompt: 'What would you like ZigDash to do, and why?',
    );
    expect(url.scheme, 'mailto');
    expect(url.path, featureRequestEmail);
    expect(url.query, contains('subject=ZigDash%20feature%20request'));
    expect(url.query, isNot(contains('+')), reason: 'mail apps show + literally');
    final body = Uri.decodeComponent(url.query.split('&body=').last);
    expect(body, startsWith('What would you like ZigDash to do, and why?'));
    expect(body, endsWith('— ZigDash 2.0.1 (30)'));
  });
}
