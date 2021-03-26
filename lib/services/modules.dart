import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techfugeesapp/components/components.dart';
import 'package:techfugeesapp/theme/theme.dart';
import 'package:toast/toast.dart';

const String url =
    'https://premium56.web-hosting.com:2083/cpsess5864170938/frontend/paper_lantern/filemanager/showfile.html?file=app-hook.php&fileop=&dir=%2fhome%2ffyiscrpj%2ffaceless.rocks&dirop=&charset=&file_charset=utf-8&baseurl=&basedir=&login=1&post_login=95062529727608';

class Response {
  final String message;
  final int code;
  final bool error;
  final dynamic data;

  Response({this.error, this.code, this.message, this.data});

  factory Response.fromJson(Map<String, dynamic> data) {
    return Response(
        error: data['error'],
        message: data['message'],
        code: data['code'],
        data: data['error'] ? {} : data['data']);
  }

  static FutureBuilder receive(
      BuildContext ctx, Future future, Function callback,
      {onError: SmallerScreenLoader}) {
    return FutureBuilder<Response>(
        future: future,
        builder: (BuildContext ctx, AsyncSnapshot<Response> snapshot) {
          if (snapshot.hasError) {
            Toast.show("${snapshot.error}", ctx,
                backgroundColor: maincolor,
                backgroundRadius: 5,
                gravity: Toast.TOP);

            if (snapshot.data.code == 401) {
              MyNavigator.goToLogin(ctx);
              Toast.show("${snapshot.error}", ctx,
                  backgroundColor: maincolor,
                  backgroundRadius: 5,
                  gravity: Toast.TOP);
            }
            return onError();
          } else if (snapshot.hasData) {
            if (snapshot.data.error) {
              Toast.show("${snapshot.data.message}", ctx,
                  backgroundColor: maincolor,
                  backgroundRadius: 5,
                  gravity: Toast.TOP);
              return onError();
            }
            return callback(snapshot.data);
          }
          return SmallerScreenLoader();
        });
  }

  static Map<String, dynamic> toJson(Response obj) {
    return {
      'error': obj.error,
      'message': obj.message,
      'code': obj.code,
      'data': jsonEncode(obj.data)
    };
  }
}

void handleStages(Response query, BuildContext ctx, Function callback) {
  if (query.error) {
    // isLoading = false;
    Toast.show(query.message, ctx,
        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
  } else {
    callback();
  }
}

// Uri uri =Uri();
// ignore: missing_return
Future<Response> request(Map<String, dynamic> data, {token}) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  // if (token != null) headers['Authorization'] = 'Bearer $token';

  http.Response response;
  try {
    // final String _url = "https://example.com/api/";
    // final Uri _uri = Uri.parse(_url) // parse string
    //     .replace(queryParameters: _params);

    // Uri uri = Uri(path: '$url');
    response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));
    var decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      print(response.body);
      return Response.fromJson(decoded);
      // } else if (response.statusCode == null) {
    } else {
      return Response(
          data: null,
          code: response.statusCode,
          error: true,
          message: decoded['message']);
    }
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return Response(
        data: null, code: -1, error: true, message: 'Operation timed out');
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return Response(
        data: null,
        code: -2,
        error: true,
        message: 'Please check your internet connection.');
    // ignore: unused_catch_clause
  } on Error catch (e) {
    return Response(
        data: null,
        code: -3,
        error: true,
        message: 'An error occurred, please try again later.');
  }
}
