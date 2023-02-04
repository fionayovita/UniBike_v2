import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';

class CustomDialog extends StatefulWidget {
  final String title, descriptions, text;
  CustomDialog(
      {required this.title, required this.descriptions, required this.text});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: 12.0, top: 50.0 + 12.0, right: 12.0, bottom: 10),
          margin: EdgeInsets.only(top: 50.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                  color: greyOutline, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions,
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    widget.text,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12.0,
          right: 12.0,
          child: CircleAvatar(
            backgroundColor: secondaryColor,
            radius: 50.0,
            child: widget.title.contains('Sukses')
                ? Icon(
                    Icons.file_download_done_rounded,
                    color: primaryColor,
                    size: 70,
                  )
                : widget.title.contains("Gagal")
                    ? Icon(
                        Icons.close,
                        color: primaryColor,
                        size: 70,
                      )
                    : Icon(
                        Icons.warning_amber,
                        color: primaryColor,
                        size: 70,
                      ),
          ),
        ),
      ],
    );
  }
}
