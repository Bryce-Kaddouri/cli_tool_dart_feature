// create a function to ask the feature name

import 'dart:io';

import 'package:args/args.dart';

import './get_template_content.dart';

String featureName = "";
String srcPath = "../lib/src";
String featurePath = "$srcPath/features/$featureName";

String businessPath = "$featurePath/business";
String dataPath = "$featurePath/data";
String presentationPath = "$featurePath/presentation";

List<Type> allDartTypes = [
  String,
  int,
  double,
  bool,
  List,
  Map,
  Set,
  DateTime,
  Object,
  Null,
];

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
        files: <FileObject>[
          FileObject(
            name: "$featureName" + "_model.dart",
            path: "$dataPath/model/$featureName" + "_model.dart",
            content: "",
          ),
        ],
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

List<String> getAllFeatures() {
  List<String> features = [];
  Directory directory = Directory('$srcPath/features');
  List<FileSystemEntity> entities = directory.listSync();
  entities.forEach((FileSystemEntity entity) {
    if (entity is Directory) {
      features.add(entity.path.split("/").last);
    }
  });
  return features;
}

List<String> getAllModels(List<String> features) {
  List<String> models = [];
  features.forEach((String feature) {
    Directory directory = Directory('$srcPath/features/$feature/data/model');
    List<FileSystemEntity> entities = directory.listSync();
    entities.forEach((FileSystemEntity entity) {
      if (entity is File) {
        models.add(entity.path.split("/").last);
      }
    });
  });
  return models;
}

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
          } else if (file.name.contains("_model.dart")) {
            String content = getModelTemplate(featureName);
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

bool checkValidType(String value) {
  // check that the type is valid
  // regex to get all type (e.g List<Map<String, dynamic>> => [List, Map, String, dynamic] or List<String> => [List, String] or int => [int])
  List<String> words = value.split(RegExp(r'[<>, ]')).where((String word) => word.isNotEmpty).toList();
  bool isValid = true;
  words.forEach((String word) {
    if (!allDartTypes.toString().contains(word)) {
      isValid = false;
    }
  });
  return isValid;
}

/*void main() {
  createFeature();
}*/

void main(List<String> arguments) {
  exitCode = 0; // Presume success
  final parser = ArgParser()
    ..addFlag('create-feature', negatable: false, abbr: 'f')
    ..addFlag('help', negatable: false, abbr: 'h')
    ..addFlag('create-method', negatable: false, abbr: 'm');

  ArgResults argResults = parser.parse(arguments);

  try {
    if (argResults['create-feature'] == true) {
      featureName = argResults.rest[0];
      createFeature();
    } else if (argResults['help'] == true) {
      print(parser.usage);
    } else if (argResults['create-method'] == true) {
      print("create-method");
      // first select the feature
      List<String> features = getAllFeatures();
      List<String> models = getAllModels(features);

      print("Select the feature:");
      for (int i = 0; i < features.length; i++) {
        print("$i. ${features[i]}");
      }
      stdout.writeln('Type the number of the feature you want to select:');
      final input = stdin.readLineSync();
      if (input == null || input.isEmpty) {
        stderr.writeln('No feature selected. Use --help for usage information.');
        exitCode = 2;
        return;
      } else if (int.tryParse(input) == null || int.parse(input) >= features.length) {
        stderr.writeln('Invalid input. Use --help for usage information.');
        exitCode = 2;
        return;
      } else {
        featureName = features[int.parse(input)];
        print("You selected: $featureName");
        print("Select the method name: (e.g. getCustomers)");
        final methodName = stdin.readLineSync();
        if (methodName == null || methodName.isEmpty) {
          stderr.writeln('No method name provided. Use --help for usage information.');
          exitCode = 2;
          return;
        } else if (!checkCamelCase(methodName)) {
          stderr.writeln('Method name must be in camelCase (e.g. getCustomers).');
          exitCode = 2;
          return;
        } else {
          print("You selected: $methodName");
          print("Select the return type: (e.g. List<CustomerModel>)");
          final returnType = stdin.readLineSync();
          if (returnType == null || returnType.isEmpty) {
            stderr.writeln('No return type provided. Use --help for usage information.');
            exitCode = 2;
            return;
          } else {
            if (!checkValidType(returnType)) {
              stderr.writeln('Invalid return type. Use --help for usage information.');
              exitCode = 2;
              return;
            }
            print("You selected: $returnType");
            print("Select the parameters type: (e.g. int, String, List<Map<String, dynamic>>)");
            final parameterType = stdin.readLineSync();
            if (parameterType == null || parameterType.isEmpty) {
              stderr.writeln('No parameter type provided. Use --help for usage information.');
              exitCode = 2;
              return;
            } else {
              if (!checkValidType(parameterType)) {
                stderr.writeln('Invalid parameter type. Use --help for usage information.');
                exitCode = 2;
                return;
              }
              print("You selected: $parameterType");
              print("Select the parameter names: (e.g. id, name, data)");
              final parameterName = stdin.readLineSync();
              if (parameterName == null || parameterName.isEmpty) {
                stderr.writeln('No parameter name provided. Use --help for usage information.');
                exitCode = 2;
                return;
              } else {
                print("You selected: $parameterName");
                print("summary:");
                print("feature: $featureName");
                print("method: $methodName");
                print("return type: $returnType");
                print("parameter type: $parameterType");
                print("parameter name: $parameterName");
                print("Do you want to create this method? (y/n)");
                final confirm = stdin.readLineSync()?.toLowerCase();
                if (confirm == "y") {
                  print("Creating method...");
                  createMethod(featureName: featureName, methodName: methodName, returnType: returnType, parameterType: parameterType, parameterName: parameterName);
                } else if (confirm == "n") {
                  print("Method creation cancelled.");
                  return;
                } else {
                  stderr.writeln('Invalid input. Use --help for usage information.');
                  exitCode = 2;
                  return;
                }
              }
            }
          }
          // select the method type
        }
      }
    } else {
      stderr.writeln('No command provided. Use --help for usage information.');
      exitCode = 2;
    }
  } catch (e) {
    stderr.writeln(e);
    exitCode = 2;
  }
}

void createMethod({
  required String featureName,
  required String methodName,
  required String returnType,
  required String parameterType,
  required String parameterName,
}) {
  String featurePath = "$srcPath/features/$featureName";
  String businessPath = "$featurePath/business";
  String dataPath = "$featurePath/data";
  String presentationPath = "$featurePath/presentation";

  String businessUseCasePath = "$businessPath/usecase";
  String businessRepositoryPath = "$businessPath/repository";
  String businessParamsPath = "$businessPath/params";

  String dataDataSourcePath = "$dataPath/datasource";
  String dataModelPath = "$dataPath/model";
  String dataRepositoryPath = "$dataPath/repository";

  String presentationProviderPath = "$presentationPath/provider";
  String presentationScreenPath = "$presentationPath/screen";
  String presentationWidgetPath = "$presentationPath/widget";

  // create the method in businessRepositoryPath
  String businessRepositoryFile = "$businessRepositoryPath/$featureName" + "_repository.dart";
  File businessRepository = File(businessRepositoryFile);
  if (!businessRepository.existsSync()) {
    _handleError(businessRepositoryFile);
    return;
  }
  String businessRepositoryContent = businessRepository.readAsStringSync();
  String methodContent = """
  Future<Either<DatabaseFailure, $returnType>> $methodName($parameterType $parameterName);
  """;
  businessRepositoryContent = businessRepositoryContent.replaceFirst("}", "$methodContent\n}");
  businessRepository.writeAsStringSync(businessRepositoryContent);

  print("Method created successfully.");
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
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
