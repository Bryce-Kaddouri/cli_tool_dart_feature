// create a function to ask the feature name

import 'dart:io';

import './get_template_content.dart';

String featureName = "";
String srcPath = "../lib/src";
String featurePath = "$srcPath/features/$featureName";

String businessPath = "$featurePath/business";
String dataPath = "$featurePath/data";
String presentationPath = "$featurePath/presentation";

List<FolderObject> folders = [
  FolderObject(
    name: "business",
    path: businessPath,
    children: [
      FolderObject(
        name: "usecase",
        path: "$businessPath/usecase",
        children: [],
      ),
      FolderObject(
        name: "repository",
        path: "$businessPath/repository",
        children: <FolderObject>[],
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_repository.dart",
            path: "$businessPath/repository/$featureName" + "_repository.dart",
            content: "",
          ),
        ],
      ),
      FolderObject(
        name: "params",
        path: "$businessPath/params",
        children: [],
      ),
    ],
  ),
  FolderObject(
    name: "data",
    path: dataPath,
    children: [
      FolderObject(
        name: "datasource",
        path: "$dataPath/datasource",
        children: [],
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_datasource.dart",
            path: "$dataPath/datasource/$featureName" + "_datasource.dart",
            content: "",
          ),
        ],
      ),
      FolderObject(
        name: "model",
        path: "$dataPath/model",
        children: [],
      ),
      FolderObject(
        name: "repository",
        path: "$dataPath/repository",
        children: [],
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_repository_impl.dart",
            path: "$dataPath/repository/$featureName" + "_repository_impl.dart",
            content: "",
          ),
        ],
      ),
    ],
  ),
  FolderObject(
    name: "presentation",
    path: presentationPath,
    children: [
      FolderObject(
        name: "provider",
        path: "$presentationPath/provider",
        children: [],
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_provider.dart",
            path: "$presentationPath/provider/$featureName" + "_provider.dart",
            content: "",
          ),
        ],
      ),
      FolderObject(
        name: "screen",
        path: "$presentationPath/screen",
        children: [],
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_screen.dart",
            path: "$presentationPath/screen/$featureName" + "_screen.dart",
            content: "",
          ),
        ],
      ),
      FolderObject(
        name: "widget",
        path: "$presentationPath/widget",
        children: [],
      ),
    ],
  ),
];

void createDirectories() {
  folders.forEach((FolderObject folder) {
    Directory(folder.path).createSync(recursive: true);
    if (folder.files != null) {
      folder.files!.forEach((FileObject file) {
        File(file.path).writeAsStringSync(file.content);
      });
    }

    folder.children.forEach((FolderObject child) {
      Directory(child.path).createSync(recursive: true);
      if (child.files != null) {
        child.files!.forEach((FileObject file) {
          File(file.path).writeAsStringSync(file.content);
          // context from repository template
          if (file.name.contains("_repository.dart")) {
            String content = getRepositoryTemplate(featureName);
            File(file.path).writeAsStringSync(content);
          } else if (file.name.contains("_datasource.dart")) {
            String content = getDataSourceTemplate(featureName);
            File(file.path).writeAsStringSync(content);
          } else if (file.name.contains("_repository_impl.dart")) {
            String content = getRepositoryImplTemplate(featureName);
            File(file.path).writeAsStringSync(content);
          } else if (file.name.contains("_screen.dart")) {
            String content = getScreenTemplate(featureName);
            File(file.path).writeAsStringSync(content);
          } else if (file.name.contains("_provider.dart")) {
            String content = getProviderTemplate(featureName);
            File(file.path).writeAsStringSync(content);
          }
        });
      }
    });
  });
}

bool checkCamelCase(String name) {
  RegExp regExp = RegExp(r'^[a-z]+(?:[A-Z][a-z]+)*$');
  return regExp.hasMatch(name);
}

bool checkSnakeCase(String name) {
  RegExp regExp = RegExp(r'^[a-z]+(?:_[a-z]+)*$');
  return regExp.hasMatch(name);
}

void askFeatureName() {
  print("Enter the feature name: ");
  featureName = stdin.readLineSync()!;
}

void createFeature() {
  askFeatureName();
  print("Feature name: $featureName");
  if (!checkSnakeCase(featureName)) {
    print("Feature name must be in snake_case (e.g. feature_name)");
    return;
  } else {
    createDirectories();
  }
  /*exit(0);*/
}

class FolderObject {
  String name;
  String path;
  List<FolderObject> children;
  List<FileObject>? files;

  FolderObject({
    required this.name,
    required this.path,
    required this.children,
    this.files,
  });
}

void main() {
  createFeature();
}

class FileObject {
  String name;
  String path;
  String content;

  FileObject({
    required this.name,
    required this.path,
    required this.content,
  });
}
