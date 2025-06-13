import 'package:realm/realm.dart';
import 'car.dart';

insertCar() {
  var config = Configuration.local([Car.schema]);
  var realm = Realm(config);

  var car = Car("Tesla", "Model Y", kilometers: 5);
  realm.write(() {
    realm.add(car);
  });
}

showCar() {
  var config = Configuration.local([Car.schema]);
  var realm = Realm(config);
  var cars = realm.all<Car>();

  Car myCar = cars[0];
  print("My car is ${myCar.make} model ${myCar.model}");

  cars = realm.all<Car>().query("make == 'Tesla'");
}
main() {
  //final realm = Realm(Configuration.local([Car]));
  print('Hello, World! 1');
  //insertCar();
  showCar();
  print('Hello, World! 2');
}