import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../../View_Model/UserProfile/EditProfileViewModel.dart';
import '../../../models/UserDetailModel.dart';
import '../widgets/colors.dart';

class editProfile extends ConsumerStatefulWidget {
  final int id;

  editProfile({required this.id});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<editProfile> {
  @override
  void dispose() {
    super.dispose();
  }

  Widget UserImage(UserDetailModel user, EditProfileViewModel model) {
    return Column(
      children: [
        GestureDetector(
          onTap: model.pickImages,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    model.uploadimage != null
                        ? FileImage(model.uploadimage!)
                        : user.image?.imageUrl != null &&
                            user.image!.imageUrl!.isNotEmpty
                        ? NetworkImage(user.image!.imageUrl!)
                        : NetworkImage(
                          "https://th.bing.com/th/id/OIP.GnqZiwU7k5f_kRYkw8FNNwHaF3?rs=1&pid=ImgDetMain",
                        ),
              ),
              Positioned(
                bottom: 5, // Adjust position of the camera icon
                right: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blueGrey,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget formFields(EditProfileViewModel model) {
    return Column(
      children: [
        TextFormField(
          controller: model.username,
          decoration: const InputDecoration(labelText: "Username"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.email,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.contactnumber,
          decoration: const InputDecoration(labelText: "Contact Number"),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.role,
          decoration: const InputDecoration(labelText: "Role"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.sector,
          decoration: const InputDecoration(labelText: "Sector"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.city,
          decoration: const InputDecoration(labelText: "City"),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: model.address,
          decoration: const InputDecoration(labelText: "Address"),
        ),
      ],
    );
  }

  Widget UpdateButton(
    AsyncValue<UserDetailModel?> state,
    EditProfileViewModel viewModel,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : () => updateData(viewModel, context),
      child:
          state.isLoading
              ? const CircularProgressIndicator()
              : const Text("Update"),
    );
  }

  void updateData(EditProfileViewModel viewModel, BuildContext context) {
    if (viewModel.key.currentState!.validate()) {
      final data = {
        'username': viewModel.username.text,
        'email': viewModel.email.text,
        'contactnumber': int.parse(viewModel.contactnumber.text),
        'role': viewModel.role.text,
        'sector': viewModel.sector.text,
        'city': viewModel.city.text,
        'address': viewModel.address.text,
      };
      print("useranme:  ${data['username']} with type:  ${data['username'].runtimeType}");
      print("email:  ${data['email']} with type:  ${data['email'].runtimeType}");
      print("contactnumber:  ${data['contactnumber']} with type:  ${data['contactnumber'].runtimeType}");
      print("password:  ${data['password']} with type:  ${data['password'].runtimeType}");
      print("role:  ${data['role']} with type:  ${data['role'].runtimeType}");
      print("sector:  ${data['sector']} with type:  ${data['sector'].runtimeType}");
      print("city:  ${data['city']} with type:  ${data['city'].runtimeType}");
      print("address:  ${data['address']} with type:  ${data['address'].runtimeType}");
      viewModel.updateUser(data, viewModel.uploadimage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(
      editProfileViewModelProvider(widget.id.toString()),
    );
    final editProfile = ref.read(
      editProfileViewModelProvider(widget.id.toString()).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: userState.when(
        loading:
            () => Center(
              child: CircularProgressIndicator(color: Appcolors.blackColor),
            ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          if (user != null) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: editProfile.key,
                child: Column(
                  children: [
                    UserImage(user, editProfile),
                    const SizedBox(height: 20),
                    formFields(editProfile),
                    const SizedBox(height: 20),
                    UpdateButton(userState, editProfile, context),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('User not found'));
          }
        },
      ),
    );
  }
}
