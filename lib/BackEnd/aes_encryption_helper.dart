import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class AESCrypt{
  final cryptor = new PlatformStringCryptor();
  Future<String> salt = null;
  Future<String> Key = null;


  AESCrypt() {
    initencryptor();
  }

  Future<String> decryptString(String encoded) async{
    try{
      final String decrypted = await cryptor.decrypt(encoded, await Key);
    }catch(e){
      e.toString();
    }
  }

  initencryptor() async{
    try {
      initSalt();
      initKey();
    }catch(e){
      e.toString();
    }
  }

  initSalt() async{
    try {
      salt = cryptor.generateSalt();
    }catch(e){
      e.toString();
    }
  }

  initKey() async{
    try {
      Key =  cryptor.generateKeyFromPassword('elink332!', await salt);
    }catch(e){
      e.toString();
    }
  }
}