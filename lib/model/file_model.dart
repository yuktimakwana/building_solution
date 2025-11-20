import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  String? fileName;
  String? fileNameLower;
  String? fileDesc;
  Timestamp? fileAddOn;

  FileModel({this.fileName, this.fileAddOn, this.fileDesc, this.fileNameLower});

  Map<String, dynamic> toMap() {
    return {
      'file_name': fileName,
      'file_name_lower': fileNameLower,
      'file_add_on': fileAddOn,
      'file_description': fileDesc,
    };
  }

  static FileModel fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileName: map['file_name'],
      fileNameLower: map['file_name_lower'],
      fileAddOn: map['file_add_on'],
      fileDesc: map['file_description'],
    );
  }
}
