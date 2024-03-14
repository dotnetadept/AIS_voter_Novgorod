import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/entity/restricted_item.dart';
import '../../State/app_state.dart';

class RightsHelper {
  Widget getRightsButton(BuildContext context, RestrictedItem item) {
    return Tooltip(
      message: 'Права',
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ),
        onPressed: () {
          Provider.of<AppState>(context, listen: false)
              .navigateToPage('/rights', args: item);
        },
        child: Icon(
          Icons.list,
          color:
              item.permissions.isNotEmpty ? Colors.greenAccent : Colors.white,
        ),
      ),
    );
  }
}
