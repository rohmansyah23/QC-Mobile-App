class CategoryModel {
  final String id;
  final String name;
  final String? iconString;

  CategoryModel({required this.id, required this.name, this.iconString});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      iconString: json['icon'],
    );
  }
}