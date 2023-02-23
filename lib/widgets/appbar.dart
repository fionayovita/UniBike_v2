import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  final String text;
  bool listBike;
  final Function onPressedFilter;

  CustomAppBar(
      {required this.text,
      required this.listBike,
      required this.onPressedFilter})
      : preferredSize = Size.fromHeight(75.0);

  @override
  final Size preferredSize;

  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<CustomAppBar> {
  bool switchColor = false;
  bool filterPressed = false;

  Color switchBgColor() {
    Color bgColor;
    switchColor ? bgColor = whiteBackground : bgColor = greyBg;
    return bgColor;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: CircleAvatar(
                        backgroundColor: mediumBlue,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: primaryColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width - 140,
                        child: Text(
                          "${widget.text}",
                          style: Theme.of(context).textTheme.headline5,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
                widget.listBike
                    ? Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: switchBgColor(),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: IconButton(
                          icon: Icon(Icons.settings_input_composite,
                              color: underline),
                          onPressed: () {
                            setState(() {
                              switchColor = !switchColor;

                              filterPressed = !filterPressed;
                            });
                            widget.onPressedFilter();
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 5),
            Divider(color: underline),
          ]),
      toolbarHeight: 70,
    );
  }
}
