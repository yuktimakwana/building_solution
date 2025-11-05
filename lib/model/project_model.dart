class ProjectModel {
  String? projectDescription;
  String? projectName;
  String? type;

  ProjectModel({this.projectName, this.projectDescription,required this.type});

  Map<String, dynamic> toMap() {
    return {
      'project_description': projectDescription,
      'project_name': projectName,
      'type': type,
    };
  }

  static ProjectModel fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      projectDescription: map['project_description'],
      projectName: map['project_name'],
      type: map['type'],
    );
  }
}
