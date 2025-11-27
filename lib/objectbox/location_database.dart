import 'package:objectbox/objectbox.dart';

@Entity()
class LocationDatabase {
  @Id()
  int id;

  String name;
  double latitude;
  double longitude;
  String timezone;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  LocationDatabase({
    this.id = 0,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}