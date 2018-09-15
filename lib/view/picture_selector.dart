import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

//图片选择组件
class PictureSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PictureSelectorState();
  }
}

class _PictureSelectorState extends State<PictureSelector> {
  List<File> images = new List();

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      images.add(new File(""));
    }
    return new GridView.count(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      crossAxisCount: 4,
      crossAxisSpacing: 5.0,
      mainAxisSpacing: 5.0,
      children: _buildList(),
    );
  }

  Widget _generateImage(File image) {
    if (image.path.isEmpty) {
      return new GestureDetector(
          onTap: () {
            _getImage();
          },
          child: new Center(
            child: new Icon(Icons.add_circle_outline,
                color: Theme.of(context).primaryColor),
          ));
    } else {
      return new GestureDetector(
          onTap: () {},
          child: Stack(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints.expand(height: 130.0),
                child: Padding(
                    padding: EdgeInsets.only(right: 10.0, top: 10.0),
                    child: new Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: 5.0,
                      height: 5.0,
                    )),
              ),
              new GestureDetector(
                child: Align(
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  alignment: Alignment.topRight,
                ),
                onTap: () {
                  setState(() {
                    images.remove(image);
                  });
                },
              ),
            ],
          ));
    }
  }

  Future _getImage() async {
    var pickImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      setState(() {
        images.insert(images.length - 1, pickImage);
      });
    }
  }

  List<Widget> _buildList() {
    List<Widget> widgets = new List();
    for (int i = 0; i < images.length; i++) {
      widgets.add(_generateImage(images[i]));
    }
    return widgets;
  }
}
