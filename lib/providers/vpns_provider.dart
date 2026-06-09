// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class VPNSProvider extends ChangeNotifier {
  static Future<List<Vpn>> getVPNServers() async {
    final vpnList = <Vpn>[];
    try {
      final res = await get(Uri.parse('http://www.vpngate.net/api/iphone/')); //
      final csvString = res.body.split('#')[1].replaceAll('*', '');

      // print("response -> $res");

      final list = csv.decode(csvString);
      //print("list size ${list.length}");
      print('csvString is -> ${list.length}');
      final header = list[0];

      for (var i = 1; i < list.length - 1; ++i) {
        final tempJson = <String, dynamic>{};

        for (var j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }
        vpnList.add(Vpn.fromJson(tempJson));
      }
    } catch (e) {
      print('Error conncect -> $e');
    }
    vpnList.shuffle();
    return vpnList;
  }

  Future<void> fetchAndSaveVpns() async {
    final CollectionReference colRef =
        FirebaseFirestore.instance.collection('VPNServers');
    final vpnsList = await getVPNServers();
    print('vpn servers -> ${vpnsList.length}');
    for (final vpn in vpnsList) {
      await colRef.doc(vpn.hostname).set(vpn.toJson());
    }
  }
}

class Vpn {
  Vpn({
    required this.hostname,
    required this.ip,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.numVpnSessions,
    required this.openVPNConfigDataBase64,
  });

  Vpn.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping'].toString();
    speed = json['Speed'] ?? 0;
    countryLong = json['CountryLong'] ?? '';
    countryShort = json['CountryShort'] ?? '';
    numVpnSessions = json['NumVpnSessions'] ?? 0;

    openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
  }
  late final String hostname;
  late final String ip;
  late final String ping;
  late final int speed;
  late final String countryLong;
  late final String countryShort;
  late final int numVpnSessions;
  late final String openVPNConfigDataBase64;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['CountryLong'] = countryLong;
    data['CountryShort'] = countryShort;
    data['NumVpnSessions'] = numVpnSessions;
    data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
    return data;
  }
}
