import 'package:flutter/material.dart';
import 'package:flutter_app_bt/models/user_info.dart';
import 'package:localstore/localstore.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  UserInfo userInfo = UserInfo();
  int currentStep = 0;
  bool isLoaded = false;

  Future<UserInfo> init() async {
    if(isLoaded) return userInfo;
    var value = await loadUserInfo();
    if (value != null) {
      try {
        isLoaded = true;
        return UserInfo.fromMap(value);
      }catch(e) {
        debugPrint(e.toString());
      }
    }
      return UserInfo();
  }



  @override
  Widget build(BuildContext context) {
    void updateStep(int value){
      if(currentStep == 0){
        if(step1FormKey.currentState!.validate()){
          step1FormKey.currentState!.save();
          setState(() {
            currentStep = value;
          });
        }
      }else if(currentStep == 1){
      }
    }
  }
}


Future<Map<String, dynamic>?> loadUserInfo() async{
  return await Localstore.instance.collection('users').doc('info').get();
}