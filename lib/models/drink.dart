import 'package:hive/hive.dart';

part 'drink.g.dart';
@HiveType(typeId: 11)
class Drink extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final bool isAlcoholic;

  Drink({required this.name, required this.timestamp, required this.isAlcoholic});
}