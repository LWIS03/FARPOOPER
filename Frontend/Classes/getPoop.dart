class Coordenates {
  final double first;   // lat
  final double second;  // lng

  const Coordenates({
    required this.first,
    required this.second,
  });

  factory Coordenates.fromJson(Map<String, dynamic> json) {
    return Coordenates(
      first: (json['first'] as num).toDouble(),
      second: (json['second'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'first': first,
    'second': second,
  };
}

class GetPoop {
  final int id;
  final int skinId;
  final String name;
  final DateTime dateCreated;
  final int points;
  final Coordenates coordenates;
  final double distanceFromHomeCords;

  const GetPoop({
    required this.id,
    required this.skinId,
    required this.name,
    required this.dateCreated,
    required this.points,
    required this.coordenates,
    required this.distanceFromHomeCords,
  });

  factory GetPoop.fromJson(Map<String, dynamic> json) {
    return GetPoop(
      id: (json['id'] as num).toInt(),
      skinId: (json['skinId'] as num).toInt(),
      name: json['name'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      points: (json['points'] as num).toInt(),
      coordenates: Coordenates.fromJson(json['coordenates'] as Map<String, dynamic>),
      distanceFromHomeCords: (json['distanceFromHomeCords'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'skinId': skinId,
    'name': name,
    'dateCreated': dateCreated.toIso8601String(),
    'points': points,
    'coordenates': coordenates.toJson(),
    'distanceFromHomeCords': distanceFromHomeCords,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GetPoop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
