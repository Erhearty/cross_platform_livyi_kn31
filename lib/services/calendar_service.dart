import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['https://www.googleapis.com/auth/calendar'],
);

class CalendarService {
  static const _kSignedIn     = 'calendar_signed_in';
  static const _kSyncEnabled  = 'calendar_sync_enabled';
  static const _kSyncPending  = 'calendar_sync_pending';

  static Future<bool> isSignedIn() => _googleSignIn.isSignedIn();

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSignedIn, true);
      await prefs.setBool(_kSyncPending, true);
      return account;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSignedIn, false);
    await prefs.setBool(_kSyncEnabled, false);
    await prefs.remove(_kSyncPending);
  }

  static Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSyncEnabled) ?? false;
  }

  static Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSyncEnabled, enabled);
  }

  static Future<bool> isSyncPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSyncPending) ?? false;
  }

  static Future<void> clearSyncPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSyncPending);
  }

  static Future<gcal.CalendarApi?> _getApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return gcal.CalendarApi(client);
  }

  static gcal.EventDateTime _eventDt(DateTime dt) =>
      gcal.EventDateTime(dateTime: dt, timeZone: 'Europe/Kiev');

  static (DateTime, DateTime) _eventRange(Task task) {
    final start = task.deadline ?? task.createdAt.add(const Duration(days: 1));
    final end   = start.add(const Duration(hours: 1));
    return (start, end);
  }

  static Future<String?> createEvent(Task task) async {
    try {
      final api = await _getApi();
      if (api == null) return null;
      final (start, end) = _eventRange(task);
      final event = gcal.Event(
        summary: task.title,
        description: task.description.isNotEmpty ? task.description : null,
        start: _eventDt(start),
        end:   _eventDt(end),
      );
      final result = await api.events.insert(event, 'primary');
      return result.id;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateEvent(Task task) async {
    if (task.calendarEventId == null) return;
    try {
      final api = await _getApi();
      if (api == null) return;
      final (start, end) = _eventRange(task);
      final event = gcal.Event(
        summary: task.title,
        description: task.description.isNotEmpty ? task.description : null,
        start: _eventDt(start),
        end:   _eventDt(end),
      );
      await api.events.update(event, 'primary', task.calendarEventId!);
    } catch (_) {}
  }

  static Future<void> deleteEvent(String eventId) async {
    try {
      final api = await _getApi();
      if (api == null) return;
      await api.events.delete('primary', eventId);
    } catch (_) {}
  }

  static Future<void> syncAllTasks(
    List<Task> tasks,
    void Function(Task) onTaskUpdated,
  ) async {
    for (final task in tasks) {
      if (task.calendarEventId == null) {
        final id = await createEvent(task);
        if (id != null) {
          task.calendarEventId = id;
          onTaskUpdated(task);
        }
      }
    }
  }
}
