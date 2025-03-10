import 'dart:io';
import 'package:ecommercefrontend/models/ProductModel.dart';
import 'package:ecommercefrontend/models/SubCategoryModel.dart';
import 'package:ecommercefrontend/models/categoryModel.dart';
import 'package:ecommercefrontend/repositories/categoriesRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/utils.dart';
import '../../repositories/product_repositories.dart';
import '../SharedViewModels/productViewModels.dart';
import 'ProductStates.dart';
import 'package:flutter/material.dart';

final addProductProvider = StateNotifierProvider.family<AddProductViewModel, ProductState, String>((ref, id,) {
      return AddProductViewModel(ref, id);
    });

class AddProductViewModel extends StateNotifier<ProductState> {
  final Ref ref;
  final String shopId;
  final ImagePicker pickImage = ImagePicker();

  AddProductViewModel(this.ref, this.shopId) : super(ProductState()) {
    getCategories();
  }

  Future<void> getCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final categories = await ref.read(categoryProvider).getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading categories: $e');
    }
  }

  Future<void> findSubcategories(String category) async {
    try {
      state = state.copyWith(isLoading: true);
      // Fetch subcategories for selected category
      final subcategories = await ref
          .read(categoryProvider)
          .FindSubCategories(category);
      state = state.copyWith(subcategories: subcategories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading subcategories: $e');
    }
  }

  Future<void> pickImages(BuildContext context) async {
    try {
      final List<XFile> pickedFiles = await pickImage.pickMultiImage();
      if (pickedFiles.isNotEmpty && state.images.length + pickedFiles.length > 7) {
        Utils.flushBarErrorMessage("Select only 7 Images", context);
        state = state.copyWith(images: state.images);
      }
      //atleast one image is selected & Previously and Newly Selected images are no more than 7
      if (pickedFiles.isNotEmpty && state.images.length + pickedFiles.length <= 7) {
        // [...] "Spread Operator" used to combine 2 lists (Previously and Newly Selected images lists)
        final newImages = [
          ...state.images,
          ...pickedFiles.map((x) => File(x.path)),
        ];
        state = state.copyWith(images: newImages);
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void removeImage(int index) {
    final newImages = List<File>.from(state.images)
      ..removeAt(index); //[..] Cascade or Chaining Opertor in list
    state = state.copyWith(images: newImages);
  }

  void setCategory(Category? category) {
    state = state.copyWith(
      selectedCategory: category,
      selectedSubcategory: null,
      subcategories: [],
    );
    if (category != null) {
      findSubcategories(category.name.toString());
    }
  }

  void setSubcategory(Subcategory? subcategory) {
    state = state.copyWith(selectedSubcategory: subcategory);
  }

  void toggleCustomCategory(bool value) {
    state = state.copyWith(
      isCustomCategory: value,
      selectedCategory: value ? null : state.selectedCategory,
      customCategoryName: value ? null : state.customCategoryName,
    );
  }

  void toggleCustomSubcategory(bool value) {
    state = state.copyWith(
      isCustomSubcategory: value,
      selectedSubcategory: value ? null : state.selectedSubcategory,
      customSubcategoryName: value ? null : state.customSubcategoryName,
    );
  }

  void setCustomCategoryName(String name) {
    state = state.copyWith(customCategoryName: name);
  }

  void setCustomSubcategoryName(String name) {
    state = state.copyWith(customSubcategoryName: name);
  }

  Future<void> addProduct({
    required String name,
    required String price,
    required String description,
    required String stock,
    required String user,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      print("Shop ID: $shopId");
      // Validate images
      if (state.images.isEmpty || state.images.length > 7) {
        throw Exception('Please select 1 to 7 images');
      }

      // Validate price and stock
      final parsedPrice = int.tryParse(price);
      final parsedStock = int.tryParse(stock);

      if (parsedPrice == null || parsedStock == null) {
        throw Exception('Price and stock must be valid numbers');
      }

      // Validate category and subcategory
      final categoryName = state.isCustomCategory ? state.customCategoryName : state.selectedCategory?.name;
      final subcategoryName = state.isCustomSubcategory ? state.customSubcategoryName : state.selectedSubcategory?.name;

      if (categoryName == null || subcategoryName == null) {
        throw Exception('Category or subcategory field is empty!');
      }

      // Prepare data for the API request
      final data = {
        'name': name,
        'price': parsedPrice, // Use parsed integer value
        'description': description,
        'stock': parsedStock, // Use parsed integer value
        'productcategory': categoryName.trim(),
        'productsubcategory': subcategoryName.trim(),
      };


      // Log request body for debugging
      print("Request Body (name): ${data['name']} with type: ${data['name'].runtimeType}");
      print("Request Body (description): ${data['description']} with type: ${data['description'].runtimeType}");
      print("Request Body (price): ${data['price']} with type: ${data['price'].runtimeType}");
      print("Request Body (stock): ${data['stock']} with type: ${data['stock'].runtimeType}");
      print("Request Body (productcategory): ${data['productcategory']} with type: ${data['productcategory'].runtimeType}");
      print("Request Body (productsubcategory): ${data['productsubcategory']} with type: ${data['productsubcategory'].runtimeType}");
      print("shopID: ${shopId} with type: ${shopId.runtimeType}");
      // Add product to the backend
      ProductModel product=await ref.read(productProvider).addProduct(data, shopId, state.images.whereType<File>().toList());
      print("Api Response ${product}");
      try {
        // Invalidate the provider to refresh the product list
        ref.invalidate(sharedProductViewModelProvider);
        await ref.read(sharedProductViewModelProvider.notifier).getShopProduct(shopId);
        await ref.read(sharedProductViewModelProvider.notifier).getAllProduct();
        await ref.read(sharedProductViewModelProvider.notifier).getUserProduct(user);
      } catch (innerError) {
        print("Error refreshing product lists: $innerError");
        // Continue with success flow despite refresh errors
      }
      // Update state and show success message
      state = state.copyWith(isLoading: false);
      Utils.toastMessage("Added Successfully!");
      Navigator.pop(context);
    } catch (e) {
      print(e);
      // Handle errors and show error message
      Utils.flushBarErrorMessage('${e}', context);
      state = state.copyWith(
        product: AsyncValue.error(e, StackTrace.current),
        isLoading: false,
      );
    }
  }
}
