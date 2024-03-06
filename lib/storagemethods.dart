import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';


class StorageMethods {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadPicToStorage(Uint8List file) async {
    // location/ref
    Reference ref = firebaseStorage.ref().child('images/');

    //  store image
    UploadTask uploadtask = ref.putData(file);

    //  wait till photo is uplaoded
    TaskSnapshot snap = await uploadtask;

    //  download url

    String url = await snap.ref.getDownloadURL();

    return url;
  }
}
