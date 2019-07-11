import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Code adapted from this tutorial: https://medium.com/flutter-community/navigate-without-context-in-flutter-with-a-navigation-service-e6d76e880c1c


GetIt locator = new GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}
  

class NavigationService {
    final GlobalKey<NavigatorState> navigatorKey =
        new GlobalKey<NavigatorState>();
    Future<dynamic> navigateTo(MaterialPageRoute route) {
      return navigatorKey.currentState.pushReplacement(route);
    }
  }