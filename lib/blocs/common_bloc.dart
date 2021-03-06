import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class CommonBloc {
  StreamController<bool> _worldDataLoadingController =
      StreamController<bool>.broadcast();
  StreamController<bool> _countriesDataLoadingController =
      StreamController<bool>();
  StreamController<bool> _indiaDataLoadingController = StreamController<bool>();

  Map worldData;
  List countryData;
  Map indiaData;

  final snackBar = SnackBar(
    content: const Text('Press back again to exit'),
    duration: snackBarDuration,
  );
  DateTime backButtonPressedTime;
  static const snackBarDuration = Duration(seconds: 3);

  Stream<bool> get worldDataLoadingStream => _worldDataLoadingController.stream;
  Stream<bool> get countriesDataLoadingStream =>
      _countriesDataLoadingController.stream;
  Stream<bool> get indiaDataLoadingStream => _indiaDataLoadingController.stream;

  void setCountriesDataLoading(bool isLoading) =>
      _countriesDataLoadingController.add(isLoading);
  void setWorldDataLoading(bool isLoading) =>
      _worldDataLoadingController.add(isLoading);
  void setIndiaDataLoading(bool isLoading) =>
      _indiaDataLoadingController.add(isLoading);

  void dispose() {
    _worldDataLoadingController.close();
    _countriesDataLoadingController.close();
    _indiaDataLoadingController.close();
  }

  Future<bool> onWillPop(BuildContext context) async {
    DateTime currentTime = DateTime.now();

    bool backButtonNotPressedTwice = backButtonPressedTime == null ||
        currentTime.difference(backButtonPressedTime) > snackBarDuration;

    if (backButtonNotPressedTwice) {
      backButtonPressedTime = currentTime;
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }
    return true;
  }

  Future<void> getWorldWideData() async {
    http.Response data = await http.get('https://corona.lmao.ninja/v2/all');
    worldData = json.decode(data.body);
    setWorldDataLoading(false);
  }

  Future<void> getCountriesData() async {
    http.Response data =
        await http.get('https://corona.lmao.ninja/v2/countries?sort=cases');
    countryData = json.decode(data.body);
    setCountriesDataLoading(false);
  }

  Future<void> getIndiaData() async {
    http.Response data = await http.get(
        'https://api.rootnet.in/covid19-in/unofficial/covid19india.org/statewise');
    indiaData = json.decode(data.body);
    setIndiaDataLoading(false);
  }

  Future<void> loadDataOnRefresh() async {
    await getWorldWideData();
    await getCountriesData();
  }

  Future<void> loadIndiaDataOnRefresh() async {
    return await getIndiaData();
  }
}
