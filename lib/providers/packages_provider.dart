// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/package/package_model.dart';

class PackagesProvider extends ChangeNotifier {
  final _packagesCollectionRef =
      FirebaseFirestore.instance.collection('Packages');

  List<PackageModel> packages = [];

  var _selectedCat = PackageType.text;

  // this will be done by admin panel
  Future sendAllPackagesInBulk() async {
    // final packages = <PackageModel>[
    //   PackageModel(
    //     id: '',
    //     type: PackageType.text,
    //     title: '15 Texts',
    //     amount: 20,
    //     duration: 0,
    //     textLimit: 15,
    //   ),
    //   PackageModel(
    //     id: '',
    //     type: PackageType.text,
    //     title: '30 Texts',
    //     amount: 37,
    //     duration: 0,
    //     textLimit: 30,
    //   ),
    //   PackageModel(
    //     id: '',
    //     type: PackageType.text,
    //     title: '50 Texts',
    //     amount: 45,
    //     duration: 0,
    //     textLimit: 50,
    //   ),
    //   PackageModel(
    //     id: '',
    //     type: PackageType.video,
    //     title: '30 Minutes Call',
    //     amount: 20,
    //     duration: 30 * 60 * 1000,
    //     textLimit: 0,
    //   ),
    //   PackageModel(
    //     id: '',
    //     type: PackageType.video,
    //     title: '1 Hour Call',
    //     amount: 37,
    //     duration: 60 * 60 * 1000,
    //     textLimit: 0,
    //   ),
    //   PackageModel(
    //     id: '',
    //     type: PackageType.video,
    //     title: '2 Hour Call',
    //     amount: 45,
    //     duration: 2 * 60 * 60 * 1000,
    //     textLimit: 0,
    //   ),
    // ];

    // for (var package in packages) {
    //   String id = _packagesCollectionRef.doc().id;
    //   package.id = id;
    //   await _packagesCollectionRef.doc(id).set(package.toJson());
    // }
  }

  Future<List<PackageModel>> getAllPackages() async {
    if (packages.isNotEmpty) return packages;
    try {
      final querySnapshots = await _packagesCollectionRef.get();
      packages = querySnapshots.docs.map((doc) {
        return PackageModel.fromJson(doc.data());
      }).toList();
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('PackagesProvider.getAllPackages: ${e.code} ${e.message}');
      }
      packages = [];
    }
    return packages;
  }

  Future<List<PackageModel>> getAllPackagesOfSelectedCategory() async {
    if (packages.isEmpty) {
      await getAllPackages();
    }
    return packages.where((element) => element.type == _selectedCat).toList();
  }

  void setSelectedCat({required PackageType cat}) {
    _selectedCat = cat;
    notifyListeners();
  }

  PackageType getSelectedCat() {
    return _selectedCat;
  }
}
