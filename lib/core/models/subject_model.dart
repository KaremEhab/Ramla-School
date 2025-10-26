class SubjectModel {
  final String id;
  final String name;

  const SubjectModel({required this.id, required this.name});

  factory SubjectModel.fromMap(Map<String, dynamic> data) {
    return SubjectModel(id: data['id'] ?? '', name: data['name'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  SubjectModel copyWith({String? id, String? name}) {
    return SubjectModel(id: id ?? this.id, name: name ?? this.name);
  }
}
