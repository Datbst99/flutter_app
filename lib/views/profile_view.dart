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
        if (value > currentStep) {
          if (step2FormKey.currentState!.validate()) {
             step2FormKey.currentState!.save();
            setState(() {
              currentStep = value;
            });
          }
        }else {
           setState(() {
              currentStep = value;
            });
        }
      } else if(currentStep == 2) {
        setState(() {
          if (value < currentStep) {
            currentStep = value;
          } else {
            saveUserInfo(userInfo).then((value) {
              showDialog<void>(
                context: context, 
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Thông báo"),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text("Hồ sơ người dùng đã được lưu thành công"),
                            Text("Bạn có thể quay lại các bước để cập nhật"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Đóng"),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          )
                      ],
                  );
                }
              );
            });
          }
        }); 
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật hồ sơ"),
        actions: [
          IconButton(
            onPressed: (){
            showDialog(
              context: context, 
              barrierDismissible: false,
              builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Xác nhận"),
                    content: const Text("Bạn có muốn xóa thông tin đã lưu?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).pop(false);
                        }, 
                      child: const Text('Hủy')
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).pop(true);
                        }, 
                      child: const Text('Đồng ý')
                      ),
                    ],
                  );
              }
            ).then((value) {
              if (value != null && value == true) {
                setState(() {
                  userInfo = UserInfo();
                });
                saveUserInfo(userInfo);
              }
            });
          }, 
          icon: const Icon(Icons.delete_outline))
        ],
      ),
      body: FutureBuilder<UserInfo>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userInfo = snapshot.data!;
            return Stepper(
              type: StepperType.horizontal,
              currentStep: currentStep,
              controlsBuilder: (context, details) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        if(currentStep == 2)
                          FilledButton(onPressed: details.onStepContinue, child: const Text("Lưu"))
                        else 
                          FilledButton(onPressed: details.onStepContinue, child: const Text("Tiếp")),
                        if(currentStep > 0)
                          TextButton(onPressed: details.onStepCancel, child: const Text("Quay lại")),
                        if(currentStep == 2) 
                          OutlinedButton(onPressed: (){}, child: const Text("Đóng"))
                      ],
                    )
                  ],
                );
              },
              onStepTapped: (value) {
                updateStep(value);
              },
              onStepContinue: () {
                updateStep(currentStep + 1);
              },
              onStepCancel: () {
                if (currentStep > 0) {
                  setState(() {
                    currentStep--;
                  });
                }
              },
              steps: [Step(title: const Text("Cơ bản"), content: Step1Form())],
            );
          } else {
            return const Center(child: LinearProgressIndicator(),);
          }
        },
      ),
    );
  }
}


class Step1Form extends StatefulWidget {
  const Step1Form({super.key});

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final nameCtl = TextEditingController();
  final dateCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final phoneCtl = TextEditingController();

  bool isEmailValid(String email) {
    String pattern = r"";

    final emailRegex = RegExp(pattern);
    return emailRegex.hasMatch(email);
  }

    bool isMobileValid(String email) {
    String pattern = r"";

    final emailRegex = RegExp(pattern);
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> saveUserInfo(UserInfo userInfo) async {
  return await Localstore.instance.collection('users').doc('info').set(userInfo.toMap());
}

Future<Map<String, dynamic>?> loadUserInfo() async{
  return await Localstore.instance.collection('users').doc('info').get();
}