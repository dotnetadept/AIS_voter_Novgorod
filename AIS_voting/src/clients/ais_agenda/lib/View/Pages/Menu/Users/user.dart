import 'dart:convert';
import 'dart:io';

import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage(this.user, {Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late User _originalUser;

  final _formKey = GlobalKey<FormState>();
  final _tecFirstName = TextEditingController();
  final _tecSecondName = TextEditingController();
  final _tecLastName = TextEditingController();
  final _tecLogin = TextEditingController();
  final _tecPassword = TextEditingController();

  @override
  void initState() {
    super.initState();

    _originalUser = User.fromJson(jsonDecode(jsonEncode(widget.user)));

    _tecFirstName.text = widget.user.firstName;
    _tecSecondName.text = widget.user.secondName;
    _tecLastName.text = widget.user.lastName;
    _tecLogin.text = widget.user.login;
    _tecPassword.text = widget.user.password;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Shell(
        title: Text('Пользователи > ${widget.user.getShortName()}'),
        actions: <Widget>[
          Tooltip(
            message: 'Сохранить',
            child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const CircleBorder(
                      side: BorderSide(color: Colors.transparent)),
                ),
              ),
              onPressed: _save,
              child: const Icon(Icons.save),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                userForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecFirstName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Имя',
            ),
            validator: (value) {
              if (value?.isEmpty != false) {
                return 'Введите имя';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecSecondName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Фамилия',
            ),
            validator: (value) {
              if (value?.isEmpty != false) {
                return 'Введите фамилию';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecLastName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Отчество',
            ),
            validator: (value) {
              if (value?.isEmpty != false) {
                return 'Введите отчество';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecLogin,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Логин',
            ),
            validator: (value) {
              if (value?.isEmpty != false) {
                return 'Введите логин';
              }
              if (AppState().getUsers().any((element) =>
                  element.id != _originalUser.id && element.login == value)) {
                return 'Уже используется';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecPassword,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Пароль',
            ),
            validator: (value) {
              if (value?.isEmpty != false) {
                return 'Введите пароль';
              }
              if (AppState().getUsers().any((element) =>
                  element.id != _originalUser.id &&
                  element.password == value)) {
                return 'Уже используется';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  bool _save() {
    if (_formKey.currentState?.validate() != true) {
      return false;
    }

    widget.user.firstName = _tecFirstName.text;
    widget.user.secondName = _tecSecondName.text;
    widget.user.lastName = _tecLastName.text;
    widget.user.login = _tecLogin.text;
    widget.user.password = _tecPassword.text;

    if (widget.user.id == '') {
      widget.user.id = const Uuid().v4();
      AppState().getUsers().add(widget.user);
    }

    File localFile = File('assets/cfg/users.json');
    localFile.writeAsStringSync(jsonEncode(AppState().getUsers()));

    Provider.of<AppState>(context, listen: false).navigateToPage('/users');

    return true;
  }

  @override
  void dispose() {
    _tecFirstName.dispose();
    _tecSecondName.dispose();
    _tecLastName.dispose();
    _tecLogin.dispose();
    _tecPassword.dispose();

    super.dispose();
  }
}
