// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_app_bt/models/address_info.dart';

class UserInfo {
  String? name;
  String? email;
  String? phoneNumber;
  DateTime? birthDate;
  AddressInfo? address;
  UserInfo({
    this.name,
    this.email,
    this.phoneNumber,
    this.birthDate,
    this.address,
  });


  factory UserInfo.fromMap(Map<String, dynamic> map){
    return UserInfo(
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        birthDate: map['birthDate'],
        address: map['address'] ? AddressInfo.fromMap(map['address'] as Map<String, dynamic>) : null
    );   
  }
}
