import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:math';

Uint8List generateRandomIV() {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(16, (index) => random.nextInt(256)));
}

String generateRandomKey() {
  final random = Random.secure();
  final keyBytes = List.generate(24, (index) => random.nextInt(256));
  return base64.encode(keyBytes);
}

String encrypt(String plaintext, String key, Uint8List iv) {
  final encryptKey = Key(utf8.encode(key));
  final encrypter =
      Encrypter(AES(encryptKey, mode: AESMode.cfb64, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(plaintext, iv: IV(iv));
  return encrypted.base64;
}

String decrypt(String ciphertext, String key, Uint8List iv) {
  final decryptKey = Key(utf8.encode(key));
  final encrypter =
      Encrypter(AES(decryptKey, mode: AESMode.cfb64, padding: 'PKCS7'));
  final decrypted = encrypter.decrypt64(ciphertext, iv: IV(iv));
  return decrypted;
}
