import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:viblify_app/models/user_model.dart';

const apiUrl = "https://fcm.googleapis.com/fcm/send";
const firebaseApiKey =
    "AAAAXs1qAN4:APA91bGXWhoHcBeI84zjcpAw6chMYZ_86k0VGdmSIuxx9z_IsGaOF85BCxl-0VMm2JObSWcg2T1JbuzPoWiCyPCOZUj-1FUlfJhGB9BGrs5C3WRdmEeAlvKjTTvUjEu2DXwmOBrOYvUm";

class APIS {
  static Future<void> pushNotification(
      UserModel chatUser, UserModel reciver, String msg, String chatid) async {
    try {
      var url = Uri.parse(apiUrl);
      var body = {
        "to": reciver.notificationsToken,
        "data": {
          "title": chatUser.name,
          "body": msg,
          "image": chatUser.profilePic,
          "chatid": chatid,
          "uid": chatUser.userID,
        }
      };
      var res = http.post(url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$firebaseApiKey'
          },
          body: jsonEncode(body));
      res;
      log(res.toString());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
