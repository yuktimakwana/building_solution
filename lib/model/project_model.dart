class ProjectModel {
  String? projectDescription;
  String? projectName;
  String? projectNameLower;
  String? type;

  ProjectModel({
    this.projectName,
    this.projectDescription,
    required this.type,
    required this.projectNameLower,
  });

  Map<String, dynamic> toMap() {
    return {
      'project_description': projectDescription,
      'project_name': projectName,
      'project_name_lower': projectNameLower,
      'type': type,
    };
  }

  static ProjectModel fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      projectDescription: map['project_description'],
      projectName: map['project_name'],
      projectNameLower: map['project_name_lower'],
      type: map['type'],
    );
  }
}
