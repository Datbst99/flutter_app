import 'dart:convert';
import 'package:flutter_app_bt/models/address_info.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bt/models/district.dart';
import 'package:flutter_app_bt/models/province.dart';
import 'package:flutter_app_bt/models/user_info.dart';
import 'package:flutter_app_bt/models/ward.dart';
import 'package:localstore/localstore.dart';
import 'package:intl/intl.dart';

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
              steps: [
                Step(
                  title: const Text("Cơ bản"), 
                  content: Step1Form(formKey: step1FormKey, userInfo: userInfo),
                  isActive: currentStep == 0,
                ),
                Step(
                  title: const Text("Địa chỉ"), 
                  content: Step2Form(formKey: step2FormKey, userInfo: userInfo),
                  isActive: currentStep == 1,
                ),
                Step(
                  title: const Text("Xác nhận"), 
                  content: ConfirmInfo(userInfo: userInfo),
                  isActive: currentStep == 2,
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }else {
            return const Center(child: LinearProgressIndicator(),);
          }
        },
      ),
    );
  }
}

class ConfirmInfo extends StatelessWidget {
  final UserInfo userInfo;
  const ConfirmInfo({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('Họ Và Tên:', userInfo.name),
          _buildInfoItem("Ngày sinh", userInfo.birthDate != null ? DateFormat('dd/MM/yyyy').format(userInfo.birthDate!) : ''),
          _buildInfoItem('Email:', userInfo.email),
          _buildInfoItem('Số điện thoại:', userInfo.phoneNumber),
          _buildInfoItem('Tỉnh / Thành phố:', userInfo.address?.province?.name),
          _buildInfoItem('Huyện / Quận:', userInfo.address?.district?.name),
          _buildInfoItem('Xã / Phường / Thị trấn:', userInfo.address?.ward?.name),
          _buildInfoItem('Địa chỉ:', userInfo.address?.street),
        ],
      ),
    );
  }
}

Widget _buildInfoItem(String label, String? value){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8.0)
      ),
      style: const TextStyle(fontSize: 16),
    ),
  );
}

class Step1Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserInfo userInfo;

  const Step1Form({super.key, required this.formKey, required this.userInfo});



  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final nameCtl = TextEditingController();
  final dateCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final phoneCtl = TextEditingController();

  bool isEmailValid(String email) {
    String pattern = r"^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$";

    final emailRegex = RegExp(pattern);
    return emailRegex.hasMatch(email);
  }

  bool isMobileValid(String email) {
    String pattern = r"/(84[3|5|7|8|9])+([0-9]{8})\b/g";

    final emailRegex = RegExp(pattern);
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    nameCtl.text = widget.userInfo.name ?? "";
    dateCtl.text = widget.userInfo.birthDate != null ? DateFormat("dd/MM/yyyy").format(widget.userInfo.birthDate!) : '';
    phoneCtl.text =  widget.userInfo.phoneNumber ?? "";
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          TextFormField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: "Họ và Tên"),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator:(value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập họ và tên";
              } 
              return null;
            },
            onChanged: (value) => widget.userInfo.name = value,
          ),
           TextFormField(
            controller: dateCtl,
            decoration: const InputDecoration(labelText: "Ngày sinh", hintText: "Nhập ngày sinh"),
            onTap: () async {
              DateTime? date = DateTime(1900);
              FocusScope.of(context).requestFocus(FocusNode());
              date = await showDatePicker(  
                context: context, 
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                initialDate: widget.userInfo.birthDate ?? DateTime.now(),
                firstDate: DateTime(1900), 
                lastDate: DateTime(2100)
              );
              if(date != null) {
                widget.userInfo.birthDate = date;
                dateCtl.text = DateFormat('dd/MM/yyyy').format(date);
              }
            },
            validator:(value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập ngày sinh";
              } 
              
              try {
                DateFormat('dd/MM/yyy').parse(value);
                return null;
              }catch(e) {
                return "Ngày sinh không hợp lệ";
              }
            },
            onChanged: (value) => widget.userInfo.name = value,
          ),
          TextFormField(
          controller: emailCtl,
          decoration: const InputDecoration(labelText: "Email"),
          keyboardType: TextInputType.emailAddress,
          validator:(value) {
            if (value == null || value.isEmpty) {
              return "Vui lòng nhập email";
            } else if(!isEmailValid(value)){
              return "Định dạng email không hợp lệ";
            }

            return null;
          },
            onChanged: (value) => widget.userInfo.email = value,
          ),
          TextFormField(
          controller: phoneCtl,
          decoration: const InputDecoration(labelText: "Số điện thoại"),
          keyboardType: TextInputType.phone,
          validator:(value) {
            if (value == null || value.isEmpty) {
              return "Vui lòng nhập số điện thoại";
            } else if(!isMobileValid(value)){
              return "Định dạng số điện thoại không hợp lệ";
            }

            return null;
          },
            onChanged: (value) => widget.userInfo.phoneNumber = value,
          ),
        ],
      ),
    );
  }
}


class Step2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserInfo userInfo;

  const Step2Form({super.key, required this.formKey, required this.userInfo});

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  final streeCtl = TextEditingController();

  List<Province> provinceList = [];
  List<District> districtList = [];
  List<Ward> wardList = [];

  @override
  void initState(){
    loadLocationData().then((value) => setState(() {}));
    super.initState();
  }

  Future<void> loadLocationData() async {
    try {
      String data = await rootBundle.loadString("assets/don_vi_hanh_chinh.json");
      Map<String, dynamic> jsonData = json.decode(data);
      List provinceData = jsonData['province'];
      provinceList = provinceData.map((e) => Province.fromMap(e)).toList();

      List districtData = jsonData['district'];
      districtList = districtData.map((e) => District.fromMap(e)).toList();

      List wardData = jsonData['ward'];
      wardList = wardData.map((e) => Ward.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Error loading location date: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    streeCtl.text = widget.userInfo.address?.street ?? '';
  
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Autocomplete<Province>(
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                WidgetsBinding.instance.addPostFrameCallback((_) { 
                  textEditingController.text = widget.userInfo.address?.province?.name ?? '';
                });
                return TextFormField(
                  decoration:  const InputDecoration(labelText: "Tỉnh / Thành Phố"),
                  controller: textEditingController,
                  focusNode: focusNode,
                  validator: (value) {
                    if(widget.userInfo.address?.province == null || value!.isEmpty) {
                      return 'Vui lòng nhập một Tỉnh/ Thành Phố';
                    }

                    return null;
                  },
                );
              },
              displayStringForOption: (option) => option.name!,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return provinceList;
                }

                return provinceList.where((element) {
                  final title = removeDiacritics(element.name ?? '');
                  final keyword = removeDiacritics(textEditingValue.text);
                  final pattern = r'\b('+ keyword + r')\b';
                  final regExp = RegExp(pattern, caseSensitive: false);
                  return title.isNotEmpty && regExp.hasMatch(title);
                });
              },
              onSelected: (option) {
                if (widget.userInfo.address?.province != option) {
                  setState(() {
                    widget.userInfo.address = AddressInfo(province: option);
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

Future<void> saveUserInfo(UserInfo userInfo) async {
  return await Localstore.instance.collection('users').doc('info').set(userInfo.toMap());
}

Future<Map<String, dynamic>?> loadUserInfo() async{
  return await Localstore.instance.collection('users').doc('info').get();
}