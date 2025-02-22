import 'package:flutter/material.dart';
import 'package:resapp/tools/colors.dart';
void showLoadingDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              color: AppColors.res_green,
            ),
            SizedBox(width: 20),
            Text(title),
          ],
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context){
    Navigator.pop(context);
}