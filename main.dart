import 'package:flutter/material.dart';
import 'package:json_http_test/MusicBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_http_test/MusicRepo.dart';
import 'package:json_http_test/trending_page.dart';
import 'SizeConfig.dart';

class MyBehavior extends ScrollBehavior{
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection){
    return child;
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        return OrientationBuilder(
          builder: (context,orientation){
            SizeConfig().init(constraints, orientation);
            return  MaterialApp(
                    builder: (context,child){
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: child,
                      );
                    },
                    title: 'Flutter Demo',
                    theme: ThemeData(
                      primarySwatch: Colors.blue,
                    ),
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Colors.grey[900],
                      body: BlocProvider(
                        builder: (context) => MusicBloc(MusicRepo()),
                        child: MusicHome(),
                      ),
                    )
                );
              },
            );
          },
        );
      }
}

