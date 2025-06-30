import 'package:realm/realm.dart';  // import realm package

part 'history_event.realm.dart'; // declare a part file.

@RealmModel() // define a data model class named `_HistoryEvent`.
class _HistoryEvent {
  late String id;

  late String title;

  late String year;

  late String simple;

  late String detail;

  late String youtube_url;
} 