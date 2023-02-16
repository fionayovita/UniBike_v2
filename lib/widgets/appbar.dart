import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String text;

  CustomAppBar({
    required this.text,
  }) : preferredSize = Size.fromHeight(65.0);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                    width: MediaQuery.of(context).size.width - 120,
                    child: Text(
                      "$text",
                      style: Theme.of(context).textTheme.headline5,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            ),
            SizedBox(height: 5),
            Divider(color: underline),
          ]),
      toolbarHeight: 70,
    );
  }
}
