import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SessionCreateForm extends StatefulWidget {
  const SessionCreateForm({Key? key}) : super(key: key);

  @override
  State<SessionCreateForm> createState() => _SessionCreateFormState();
}

enum SessionType {
  follower,
  poly
}

class _SessionCreateFormState extends State<SessionCreateForm> {
  final _formKey = GlobalKey<FormState>();

  SessionType typeSelected = SessionType.follower;
  int duration = 15;

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Session Type"),
          RadioListTile<SessionType>(
              title: const Text("Follower"),
              value: SessionType.follower,
              groupValue: typeSelected,
              onChanged: (val) {
                setState(() {
                  typeSelected = val!;
                });
              }
          ),
          RadioListTile<SessionType>(
              title: const Text("Polygon"),
              value: SessionType.poly,
              groupValue: typeSelected,
              onChanged: (val) {
                //  Disabled for now
              }
          ),
          const SizedBox(height: 6),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (val) {
              duration = int.tryParse(val) ?? 15;
            },
            validator: (val) {
              if(val == null){
                return "Enter in a number between 15 and 45";
              }

              var num = int.tryParse(val);
              if(num == null){
                return "Only valid numbers are accepted";
              }

              if(num < 15 || num > 45){
                return "Range 15 to 45 only";
              }

              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Duration (in minutes)"
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40)
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                var httpsCallable = FirebaseFunctions.instance.httpsCallable("createSession");

                Get.rawSnackbar(
                  message: "Creating Session..."
                );

                var response = await httpsCallable.call({
                  "expire": duration
                });

                if(response.data?["message"] != null){
                  await Get.closeCurrentSnackbar();
                  Get.rawSnackbar(
                    message: response.data!["message"]
                  );
                }
              }, child: const Text("Submit"))
        ],
      ),
    );
  }
}

class SessionCreatePopup extends StatelessWidget {
  const SessionCreatePopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create a Guardian Session"),
      content: const SessionCreateForm(),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"))
      ],
    );
  }
}
