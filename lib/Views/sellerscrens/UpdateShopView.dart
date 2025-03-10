import 'dart:io';
import 'package:ecommercefrontend/View_Model/SellerViewModels/UpdateShopViewModel.dart';
import 'package:ecommercefrontend/models/shopModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/utils.dart';
import '../shared/widgets/ImageWidgetInUpdateView.dart';
import '../shared/widgets/ShopCategoryDropDownMenu.dart';
import '../shared/widgets/colors.dart';

class updateShopView extends ConsumerStatefulWidget {
  int id;
  String userid;
  updateShopView({required this.id,required this.userid});

  @override
  ConsumerState<updateShopView> createState() => _updateShopViewState();
}

class _updateShopViewState extends ConsumerState<updateShopView> {
  final formkey = GlobalKey<FormState>();
  late TextEditingController shopname = TextEditingController();
  late TextEditingController shopaddress = TextEditingController();
  late TextEditingController sector = TextEditingController();
  late TextEditingController city = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateShopProvider(widget.id.toString()).notifier).initValues(widget.id.toString())
          .then((_) {
            final shop = ref.read(updateShopProvider(widget.id.toString())).value;
            print('Loaded shop: ${shop}');
            if (shop != null) {
              shopname.text = shop.shopname ?? '';
              shopaddress.text = shop.shopaddress ?? '';
              sector.text = shop.sector ?? '';
              city.text = shop.city ?? '';
            }
          });
      ref.read(updateShopProvider(widget.id.toString()).notifier).getCategories();
    });
  }

  @override
  void dispose() {
    shopaddress.dispose();
    shopname.dispose();
    sector.dispose();
    city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateShopProvider(widget.id.toString()));
    return Scaffold(
      appBar: AppBar(title: Text("Update Shop")),
      body: state.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (shop) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (state.value?.images != null &&
                        state.value!.images!.isNotEmpty)
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.value?.images?.length ?? 0,
                          itemBuilder: (context, index) {
                            final image = state.value!.images?[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: UpdateImage(image),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red,),
                                      onPressed: () {
                                        ref.read(updateShopProvider(widget.id.toString(),).notifier,).removeImage(index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(updateShopProvider(widget.id.toString()).notifier,).pickImages(context);
                        },
                      child: Text("Upload Images"),
                    ),
                    TextFormField(
                      controller: shopname,
                      decoration: InputDecoration(labelText: "Shop Name"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a Shop name";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: shopaddress,
                      decoration: InputDecoration(labelText: "Shop Address"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: sector,
                      decoration: InputDecoration(labelText: "Sector"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter Sector";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: city,
                      decoration: InputDecoration(labelText: "city"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter city";
                        }
                        return null;
                      },
                    ),
                    UpdateShopcategoryDropdown(userid: widget.id.toString()),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: state.isLoading ? null : () async {
                                if (formkey.currentState!.validate()) {
                                  print("shopname: ${shopname.text}, shopaddress: ${shopaddress.text}, Sector: ${sector.text}, City: ${city.text}",); // Debugging line

                                  await ref.read(updateShopProvider(widget.id.toString(),).notifier,)
                                      .updateShop(shopname: shopname.text, shopaddress: shopaddress.text, sector: sector.text, city: city.text,userid:widget.userid.toString(), context: context,);
                                }
                              },
                      child: state.isLoading ? Center(child: CircularProgressIndicator(color: Appcolors.blueColor,),)
                              : const Text('Update Shop'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
