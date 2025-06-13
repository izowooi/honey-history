import 'package:realm/realm.dart';  // import realm package

part 'car.realm.dart'; // declare a part file.

@RealmModel() // define a data model class named `_Car`.
class _Car {
  late String make;

  late String model;

  int? kilometers = 500;
}