import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unibike/common/styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final Function onPressedPinjam;
  final String text;

  const ConfirmationDialog({required this.onPressedPinjam, required this.text});

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
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 50), primary: whiteBackground),
                    child: Text(
                      "Tidak",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPressedPinjam();
                    },
                    style: ElevatedButton.styleFrom(minimumSize: Size(120, 50)),
                    child: Text("Ya",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                          color: primaryColor,
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
