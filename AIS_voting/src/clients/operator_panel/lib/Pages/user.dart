import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:global_configuration/global_configuration.dart';

class UserPage extends StatefulWidget {
  final User user;
  final List<User> users;
  UserPage({Key key, this.user, this.users}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User _originalUser;
  final _formKey = GlobalKey<FormState>();
  var _tecFirstName = TextEditingController();
  var _tecSecondName = TextEditingController();
  var _tecLastName = TextEditingController();
  var _tecLogin = TextEditingController();
  var _tecPassword = TextEditingController();
  var _tecCardId = TextEditingController();

  @override
  void initState() {
    super.initState();

    _originalUser = User.fromJson(jsonDecode(jsonEncode(widget.user)));

    _tecFirstName.text = widget.user.firstName;
    _tecSecondName.text = widget.user.secondName;
    _tecLastName.text = widget.user.lastName;
    _tecLogin.text = widget.user.login;
    _tecPassword.text = widget.user.password;
    _tecCardId.text = widget.user.cardId;
    if (widget.user.isVoter == null) {
      widget.user.isVoter = false;
    }
  }

  bool _save() {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    widget.user.firstName = _tecFirstName.text;
    widget.user.secondName = _tecSecondName.text;
    widget.user.lastName = _tecLastName.text;
    widget.user.login = _tecLogin.text;
    widget.user.password = _tecPassword.text;
    widget.user.cardId = _tecCardId.text;

    if (widget.user.id == 0) {
      http
          .post(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/users'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.user.toJson()))
          .then((value) => Navigator.pop(context));
    } else {
      var userId = widget.user.id;
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/users/$userId'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.user.toJson()))
          .then((value) => Navigator.pop(context));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var shouldNavigateBack = true;
        //check for unsaved changes
        if (widget.user.firstName != _tecFirstName.text ||
            widget.user.secondName != _tecSecondName.text ||
            widget.user.lastName != _tecLastName.text ||
            widget.user.login != _tecLogin.text ||
            widget.user.password != _tecPassword.text ||
            widget.user.cardId != _tecCardId.text ||
            _originalUser.isVoter != widget.user.isVoter) {
          await Utility().showYesNoDialog(
            context,
            title: 'Проверка',
            message: TextSpan(
              text: 'Имеются несохраненные изменения. Сохранить?',
            ),
            yesButtonText: 'Да',
            yesCallBack: () {
              if (!_save()) {
                shouldNavigateBack = false;
                Navigator.of(context).pop();
              }
            },
            noButtonText: 'Нет',
            noCallBack: () {
              Navigator.of(context).pop();
            },
          );
        }

        //trigger leaving and use own data
        if (shouldNavigateBack) {
          Navigator.pop(context, false);
        }

        //we need to return a future
        return Future.value(false);
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Назад',
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(widget.user.id == 0
                ? 'Новый пользователь'
                : 'Изменить пользователя ${_originalUser.toString()}'),
            centerTitle: true,
            actions: <Widget>[
              Tooltip(
                message: 'Сохранить',
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: _save,
                  child: Icon(Icons.save),
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Имя',
            ),
            validator: (value) {
              if (value.isEmpty) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Фамилия',
            ),
            validator: (value) {
              if (value.isEmpty) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Отчество',
            ),
            validator: (value) {
              if (value.isEmpty) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Логин',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Введите логин';
              }
              if (widget.users.any((element) =>
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Пароль',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Введите пароль';
              }
              if (widget.users.any((element) =>
                  element.id != _originalUser.id &&
                  element.password == value)) {
                return 'Уже используется';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecCardId,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ключ карты',
            ),
            validator: (value) {
              if (!(value == null && value.isEmpty)) {
                if (widget.users.any((element) =>
                    element.id != _originalUser.id &&
                    element.cardId == value)) {
                  return 'Уже используется';
                }
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Голосует:'),
                Switch(
                    value: widget.user.isVoter,
                    onChanged: (value) => {
                          setState(() {
                            widget.user.isVoter = value;
                          })
                        }),
              ]),
        ),
      ],
    );
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
