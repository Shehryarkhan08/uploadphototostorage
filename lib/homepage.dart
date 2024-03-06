import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_upload/utils.dart';
import 'package:photo_upload/imagepicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_upload/storagemethods.dart';


// ignore_for_file: use_build_context_synchronously

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  bool _isLoading = false;
  Uint8List? _file;
  late TextEditingController _postController = TextEditingController();
  bool _isTextEntered = false;
  bool _isImageFullscreen = false;

  @override
  void initState() {
    super.initState();
    _postController = TextEditingController();
    _postController.addListener(_updateTextEntered);
  }

  void _updateTextEntered() {
    setState(() {
      _isTextEntered = _postController.text.isNotEmpty;
    });
  }

  void postContent() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await StorageMethods().uploadPicToStorage(_file!);

      if (res == 'success') {
        setState(() {
          _isLoading = false;
        });
        showSnakBars('posted', context);
        // Navigator.popAndPushNamed(context, const AddPostScreen().toString());
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnakBars(res, context);
      }
    } catch (err) {
      showSnakBars(err.toString(), context);
    }
  }

  Future<void> _selectImage(BuildContext context) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Card(
                color: Colors.grey.shade200,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Upload a video to your workspace',
                        style: TextStyle(
                            fontSize: 17, color: Colors.grey.shade500),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Center(
                        child: Text(
                          'Take a photo',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        Uint8List? file = await pickImage(ImageSource.camera);
                        if (file != null) {
                          setState(() {
                            _file = file;
                            _isImageFullscreen = false;
                          });
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Choose from gallery',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        Uint8List? file = await pickImage(ImageSource.gallery);
                        if (file != null) {
                          setState(() {
                            _file = file;
                            _isImageFullscreen = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.grey.shade200,
                child: ListTile(
                  title: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade300,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.grey.shade300,
        title: Container(
          margin: const EdgeInsets.only(top: 20, left: 10),
          child: CircleAvatar(
            radius: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 20),
            alignment: Alignment.center,
            width: 60,
            height: 34,
            decoration: ShapeDecoration(
              color: _isTextEntered
                  // ? const Color.fromARGB(255, 13, 75, 127)
                  ? Colors.blue
                  : Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: TextButton(
              onPressed: () => postContent(),
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 14,
                  color: _isTextEntered ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _isLoading
                  ? const LinearProgressIndicator()
                  : const Padding(padding: EdgeInsets.only(top: 0)),
              const Divider(),
              TextField(
                controller: _postController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: InputBorder.none,
                ),
                onTap: () {
                  setState(() {
                    _isImageFullscreen = false;
                  });
                },
              ),
              const SizedBox(height: 5),
              if (_file != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isImageFullscreen = !_isImageFullscreen;
                    });
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: _isImageFullscreen
                        ? MediaQuery.of(context).size.height - 200
                        : 500,
                    child: Image.memory(
                      _file!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // backgroundColor: const Color.fromARGB(255, 13, 75, 127),
        backgroundColor: Colors.blue,

        onPressed: () {
          _selectImage(context);
        },
        child: const Icon(Icons.image),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
