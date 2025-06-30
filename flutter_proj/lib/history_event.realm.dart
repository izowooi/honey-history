// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_event.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class HistoryEvent extends _HistoryEvent
    with RealmEntity, RealmObjectBase, RealmObject {
  HistoryEvent(
    String id,
    String title,
    String year,
    String simple,
    String detail,
    String youtube_url,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'simple', simple);
    RealmObjectBase.set(this, 'detail', detail);
    RealmObjectBase.set(this, 'youtube_url', youtube_url);
  }

  HistoryEvent._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get year => RealmObjectBase.get<String>(this, 'year') as String;
  @override
  set year(String value) => RealmObjectBase.set(this, 'year', value);

  @override
  String get simple => RealmObjectBase.get<String>(this, 'simple') as String;
  @override
  set simple(String value) => RealmObjectBase.set(this, 'simple', value);

  @override
  String get detail => RealmObjectBase.get<String>(this, 'detail') as String;
  @override
  set detail(String value) => RealmObjectBase.set(this, 'detail', value);

  @override
  String get youtube_url =>
      RealmObjectBase.get<String>(this, 'youtube_url') as String;
  @override
  set youtube_url(String value) =>
      RealmObjectBase.set(this, 'youtube_url', value);

  @override
  Stream<RealmObjectChanges<HistoryEvent>> get changes =>
      RealmObjectBase.getChanges<HistoryEvent>(this);

  @override
  Stream<RealmObjectChanges<HistoryEvent>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<HistoryEvent>(this, keyPaths);

  @override
  HistoryEvent freeze() => RealmObjectBase.freezeObject<HistoryEvent>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'year': year.toEJson(),
      'simple': simple.toEJson(),
      'detail': detail.toEJson(),
      'youtube_url': youtube_url.toEJson(),
    };
  }

  static EJsonValue _toEJson(HistoryEvent value) => value.toEJson();
  static HistoryEvent _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'year': EJsonValue year,
        'simple': EJsonValue simple,
        'detail': EJsonValue detail,
        'youtube_url': EJsonValue youtube_url,
      } =>
        HistoryEvent(
          fromEJson(id),
          fromEJson(title),
          fromEJson(year),
          fromEJson(simple),
          fromEJson(detail),
          fromEJson(youtube_url),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(HistoryEvent._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, HistoryEvent, 'HistoryEvent', [
      SchemaProperty('id', RealmPropertyType.string),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('year', RealmPropertyType.string),
      SchemaProperty('simple', RealmPropertyType.string),
      SchemaProperty('detail', RealmPropertyType.string),
      SchemaProperty('youtube_url', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
