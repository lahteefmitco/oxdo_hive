import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  Person(this.name, this.age);
}