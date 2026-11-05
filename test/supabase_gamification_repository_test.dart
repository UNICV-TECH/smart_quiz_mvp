// Unit tests for SupabaseGamificationRepository against a fake PostgREST.
//
// A real SupabaseClient is built on top of an in-memory http client, so the
// tests assert the exact query string the app sends (filters, order, limit)
// without a running Supabase.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// http is a transitive dependency of supabase_flutter; only the testing
// helper is used here.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unicv_tech_mvp/models/gamification_points.dart';
import 'package:unicv_tech_mvp/repositories/supabase_gamification_repository.dart';

typedef _Handler = Object Function(http.Request request);

class _FakePostgrest {
  _FakePostgrest(this.handler);

  final _Handler handler;
  final List<http.Request> requests = [];

  SupabaseGamificationRepository repository() {
    final client = SupabaseClient(
      'http://localhost:54321',
      'test-anon-key',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode(handler(request)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
          request: request,
        );
      }),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    return SupabaseGamificationRepository(client: client);
  }

  List<http.Request> to(String table) =>
      requests.where((r) => r.url.path == '/rest/v1/$table').toList();
}

Map<String, dynamic> _rankingRow(int position, double points) => {
      'user_id': 'user-$position',
      'season_id': 'season-1',
      'user_name': 'Aluno $position',
      'avatar_url': null,
      'season_points': points,
      'total_attempts': 1,
      'rank_position': position,
      'exam_template_id': 'template-1',
      'template_name': 'Prova',
      'course_id': 'course-1',
      'course_name': 'Curso',
    };

void main() {
  group('saveAttemptPoints reports the season total (level source)', () {
    // Scenario of the bug report: the student already has 97 pts in the season
    // from other exams and scores 10 pts on a template for the first time. The
    // ranking shows 107 pts, so the result screen must get 107 too (not 10).
    Object Function(http.Request) handler({
      required List<double> templateRecords,
      required List<double> seasonRecords,
    }) {
      return (request) {
        final path = request.url.path;
        final query = request.url.queryParameters;
        if (path == '/rest/v1/exam') {
          return {'id_exam_template': 'template-1'};
        }
        if (path == '/rest/v1/user_gamification_points') {
          if (request.method == 'POST') return <Object>[];
          final rows = query.containsKey('exam_template_id')
              ? templateRecords
              : seasonRecords;
          return rows.map((p) => {'total_points': p}).toList();
        }
        throw StateError('unexpected request: ${request.method} $path');
      };
    }

    Future<SavePointsResult> save(_FakePostgrest fake, double totalPoints) {
      return fake.repository().saveAttemptPoints(
            userId: 'user-1',
            seasonId: 'season-1',
            attemptId: 'attempt-1',
            examId: 'exam-1',
            courseId: 'course-1',
            questionCount: 5,
            correctCount: 5,
            percentageScore: 100,
            durationSeconds: 60,
            basePoints: 5,
            timeBonus: 5,
            totalPoints: totalPoints,
          );
    }

    test('first attempt on the template: 97 + 10 = 107 in the season',
        () async {
      // After the insert the season query already sees the new 10 pts row.
      final fake = _FakePostgrest(
        handler(templateRecords: [], seasonRecords: [97, 10]),
      );

      final result = await save(fake, 10);

      expect(result.didImprove, isTrue);
      expect(result.pointsSaved, 10);
      expect(result.accumulatedPoints, 10, reason: 'best of this template');
      expect(result.seasonPoints, 107);
      expect(result.previousSeasonPoints, 97);

      final season = fake
          .to('user_gamification_points')
          .where((r) => r.method == 'GET')
          .map((r) => r.url.queryParameters)
          .firstWhere((q) => !q.containsKey('exam_template_id'));
      expect(season['user_id'], 'eq.user-1');
      expect(season['season_id'], 'eq.season-1');
    });

    test('no improvement: nothing saved, season total unchanged', () async {
      final fake = _FakePostgrest(
        handler(templateRecords: [10], seasonRecords: [97, 10]),
      );

      final result = await save(fake, 8);

      expect(result.didImprove, isFalse);
      expect(result.pointsSaved, 0);
      expect(result.seasonPoints, 107);
      expect(result.previousSeasonPoints, 107);
      expect(
        fake.to('user_gamification_points').where((r) => r.method == 'POST'),
        isEmpty,
      );
    });
  });

  group('rankings are requested 1st → last', () {
    // The fake returns rows in the order PostgREST would for the requested
    // direction, so a descending request reproduces the reported bug.
    Object rankingHandler(http.Request request) {
      final rows = [
        _rankingRow(1, 40),
        _rankingRow(2, 25),
        _rankingRow(3, 12),
      ];
      final order = request.url.queryParameters['order'] ?? '';
      return order.startsWith('rank_position.desc')
          ? rows.reversed.toList()
          : rows;
    }

    test('template ranking (Gamificação do professor)', () async {
      final fake = _FakePostgrest(rankingHandler);
      final ranking = await fake.repository().getTemplateRanking(
            templateId: 'template-1',
            seasonId: 'season-1',
          );

      final query = fake.to('ranking_template_view').single.url.queryParameters;
      expect(query['order'], startsWith('rank_position.asc'));
      expect(query['limit'], '50');
      expect(ranking.map((e) => e.rankPosition), [1, 2, 3]);
      expect(ranking.first.seasonPoints, 40);
    });

    test('global ranking', () async {
      final fake = _FakePostgrest(rankingHandler);
      final ranking =
          await fake.repository().getGlobalRanking(seasonId: 'season-1');

      expect(
        fake.to('ranking_global_view').single.url.queryParameters['order'],
        startsWith('rank_position.asc'),
      );
      expect(ranking.map((e) => e.rankPosition), [1, 2, 3]);
    });

    test('course ranking', () async {
      final fake = _FakePostgrest(rankingHandler);
      final ranking = await fake.repository().getCourseRanking(
            seasonId: 'season-1',
            courseId: 'course-1',
          );

      expect(
        fake.to('ranking_course_view').single.url.queryParameters['order'],
        startsWith('rank_position.asc'),
      );
      expect(ranking.map((e) => e.rankPosition), [1, 2, 3]);
    });
  });
}
