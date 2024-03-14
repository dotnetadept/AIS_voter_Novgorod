import 'dart:convert';
import 'dart:async';
import 'package:ais_agenda/Model/entity/aisform_type.dart';
import 'package:ais_agenda/Model/subject/permission.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../Model/agenda/agenda.dart';
import '../Model/entity/aisform.dart';
import '../Model/entity/form_field_type.dart';
import '../Model/entity/utility/validator_type.dart';
import '../Model/subject/aisaction.dart';
import '../Model/subject/group.dart';
import '../Model/subject/user.dart';

class AppState with ChangeNotifier {
  static late AppState _singleton;

  GlobalKey<NavigatorState>? navigatorKey;

  static String _currentPage = '';
  static String _previousPage = '';
  static String _previousNavPath = '';
  static late User _currentUser;
  static bool _isLoadingComplete = false;

  static late List<User> _users;
  static late List<Group> _groups;

  static late List<AisAction> _actions;
  static late List<Permission> _permissions;

  static late List<AisFormType> _formTypes;
  static late List<AisForm> _forms;
  static late List<FormFieldType> _formFieldTypes;
  static late List<ValidatorType> _validatorTypes;

  static late List<Agenda> _agendas;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _singleton = AppState(navigatorKey: navigatorKey);
  }

  static AppState getInstance() {
    return _singleton;
  }

  AppState({this.navigatorKey});

  Future<void> loadData() async {
    String users = await rootBundle.loadString('assets/cfg/users.json');
    AppState().setUsers((json.decode(users) as List)
        .map((data) => User.fromJson(data))
        .toList());

    String groups = await rootBundle.loadString('assets/cfg/groups.json');
    AppState().setGroups((json.decode(groups) as List)
        .map((data) => Group.fromJson(data))
        .toList());

    String formsTypes =
        await rootBundle.loadString('assets/cfg/formTypes.json');
    AppState().setFormTypes((json.decode(formsTypes) as List)
        .map((data) => AisFormType.fromJson(data))
        .toList());

    String forms = await rootBundle.loadString('assets/cfg/forms.json');
    AppState().setForms((json.decode(forms) as List)
        .map((data) => AisForm.fromJson(data))
        .toList());

    String formFieldTypes =
        await rootBundle.loadString('assets/cfg/formFieldType.json');
    AppState().setFormFieldTypes((json.decode(formFieldTypes) as List)
        .map((data) => FormFieldType.fromJson(data))
        .toList());

    String validatorTypes =
        await rootBundle.loadString('assets/cfg/validatorType.json');
    AppState().setValidatorTypes((json.decode(validatorTypes) as List)
        .map((data) => ValidatorType.fromJson(data))
        .toList());

    String actions = await rootBundle.loadString('assets/cfg/actions.json');
    AppState().setActions((json.decode(actions) as List)
        .map((data) => AisAction.fromJson(data))
        .toList());

    String permissions =
        await rootBundle.loadString('assets/cfg/permissions.json');
    AppState().setPermission((json.decode(permissions) as List)
        .map((data) => Permission.fromJson(data))
        .toList());

    String agendas = await rootBundle.loadString('assets/cfg/agendas.json');
    AppState().setAgendas((json.decode(agendas) as List)
        .map((data) => Agenda.fromJson(data))
        .toList());

    setIsLoadingComplete(true);

    await navigateToPage('/login');
  }

  Future<void> navigateToPage(String page, {Object? args}) async {
    // executes navigation after build
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _setCurrentPage(page);
      await navigatorKey?.currentState?.pushNamedAndRemoveUntil(
          page, (Route<dynamic> route) => false,
          arguments: args);
    });
  }

  void _setCurrentPage(String currentPage) {
    _previousPage = _currentPage;
    _currentPage = currentPage;
    //notifyListeners();
  }

  String getCurrentPage() {
    return _currentPage;
  }

  String getPreviousPage() {
    return _previousPage;
  }

  void setPreviousNavPath(String previousNavPath) {
    _previousNavPath = previousNavPath;
  }

  String getPreviousNavPath() {
    return _previousNavPath;
  }

  bool getIsLoadingComplete() {
    return _isLoadingComplete;
  }

  void setIsLoadingComplete(bool isLoadingComplete) {
    _isLoadingComplete = isLoadingComplete;
    //notifyListeners();
  }

  User getCurrentUser() {
    return _currentUser;
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    //notifyListeners();
  }

  List<User> getUsers() {
    return _users;
  }

  void setUsers(List<User> users) {
    _users = users;
  }

  List<Group> getGroups() {
    return _groups;
  }

  void setGroups(List<Group> groups) {
    _groups = groups;
  }

  List<AisForm> getForms() {
    return _forms;
  }

  void setForms(List<AisForm> forms) {
    _forms = forms;
  }

  List<AisFormType> getFormTypes() {
    return _formTypes;
  }

  void setFormTypes(List<AisFormType> formTypes) {
    _formTypes = formTypes;
  }

  List<FormFieldType> getFormFieldTypes() {
    return _formFieldTypes;
  }

  void setFormFieldTypes(List<FormFieldType> formFieldTypes) {
    _formFieldTypes = formFieldTypes;
  }

  List<ValidatorType> geValidatorTypes() {
    return _validatorTypes;
  }

  void setValidatorTypes(List<ValidatorType> validatorTypes) {
    _validatorTypes = validatorTypes;
  }

  List<AisAction> getActions() {
    return _actions;
  }

  void setActions(List<AisAction> actions) {
    _actions = actions;
  }

  List<Permission> getPermissions() {
    return _permissions;
  }

  void setPermission(List<Permission> permissions) {
    _permissions = permissions;
  }

  List<Agenda> getAgendas() {
    return _agendas;
  }

  void setAgendas(List<Agenda> agendas) {
    _agendas = agendas;
  }
}
