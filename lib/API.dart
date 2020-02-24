import 'dart:core';

import 'APIRequest.dart';

class API
{
  int _ID;
  String _name;
  String _apiKey;

  String get apiKey => _apiKey;
  List<APIRequest> _apiRequestsList;

  API(this._name, this._apiKey) {
    _apiRequestsList = List<APIRequest>();
  }

  void addAPIRequest(APIRequest newRequest)
  {
    _apiRequestsList.add(newRequest);
  }

  Future makeRequest(String name) async{
    for(APIRequest request in _apiRequestsList)
    {
      if(request.name == name)
      {
        //the "await" here is good, the IDE must be crazy
        await request.makeRequest(this);
        break;
      }
    }
  }
}