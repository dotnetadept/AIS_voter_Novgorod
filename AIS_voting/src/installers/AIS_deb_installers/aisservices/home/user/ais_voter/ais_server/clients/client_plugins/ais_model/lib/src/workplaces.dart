class Workplaces {
  bool hasManagement;
  int managementPlacesCount;
  bool hasTribune;
  int tribunePlacesCount;
  int rowsCount;
  List<int> rows;
  List<bool> isDisplayEmptyCell;
  List<int> schemeManagement;
  List<String> managementTerminalIds;
  List<String> tribuneTerminalIds;
  List<String> tribuneNames;
  List<List<int>> schemeWorkplaces;
  List<List<String>> workplacesTerminalIds;

  Workplaces() {
    hasManagement = false;
    managementPlacesCount = 0;
    hasTribune = false;
    tribunePlacesCount = 0;
    rowsCount = 0;
    rows = <int>[];
    isDisplayEmptyCell = <bool>[];
    schemeManagement = <int>[];
    managementTerminalIds = <String>[];
    tribuneTerminalIds = <String>[];
    tribuneNames = <String>[];
    schemeWorkplaces = <List<int>>[];
    workplacesTerminalIds = <List<String>>[];
  }

  int getTotalPlacesCount() {
    var totalSum = managementPlacesCount;
    rows.forEach((element) {
      totalSum += element;
    });
    return totalSum;
  }

  int getTotalUsersCount() {
    var totalCount =
        schemeManagement.where((element) => element != null).length;

    schemeWorkplaces.forEach((element) {
      totalCount += element.where((element) => element != null).length;
    });

    return totalCount;
  }

  String getTerminalIdByUserId(int userId) {
    if (userId == null) {
      return '0xfff';
    }
    for (var i = 0; i < schemeManagement.length; i++) {
      if (schemeManagement[i] == userId) {
        return managementTerminalIds[i];
      }
    }

    for (var i = 0; i < schemeWorkplaces.length; i++) {
      for (var j = 0; j < schemeWorkplaces[i].length; j++) {
        if (schemeWorkplaces[i][j] == userId) {
          return workplacesTerminalIds[i][j];
        }
      }
    }

    return null;
  }

  Map toJson() => {
        'hasManagement': hasManagement,
        'tribunePlacesCount': tribunePlacesCount,
        'hasTribune': hasTribune,
        'managementPlacesCount': managementPlacesCount,
        'rowsCount': rowsCount,
        'rows': rows,
        'isDisplayEmptyCell': isDisplayEmptyCell,
        'schemeManagement': schemeManagement,
        'managementTerminalIds': managementTerminalIds,
        'tribuneTerminalIds': tribuneTerminalIds,
        'tribuneNames': tribuneNames,
        'schemeWorkplaces': schemeWorkplaces,
        'workplacesTerminalIds': workplacesTerminalIds,
      };

  Workplaces.fromJson(Map<String, dynamic> json)
      : hasManagement = json['hasManagement'],
        managementPlacesCount = json['managementPlacesCount'],
        hasTribune = json['hasTribune'],
        tribunePlacesCount = json['tribunePlacesCount'],
        rowsCount = json['rowsCount'],
        rows = json['rows'].toList().cast<int>(),
        isDisplayEmptyCell = json['isDisplayEmptyCell'].toList().cast<bool>(),
        schemeManagement = json['schemeManagement'].toList().cast<int>(),
        managementTerminalIds =
            json['managementTerminalIds'].toList().cast<String>(),
        tribuneTerminalIds = json['tribuneTerminalIds'].toList().cast<String>(),
        tribuneNames = json['tribuneNames'].toList().cast<String>(),
        schemeWorkplaces = json['schemeWorkplaces'].map<List<int>>((i) {
          return List<int>.from(i);
        }).toList(),
        workplacesTerminalIds =
            json['workplacesTerminalIds'].map<List<String>>((i) {
          return List<String>.from(i);
        }).toList();
}
