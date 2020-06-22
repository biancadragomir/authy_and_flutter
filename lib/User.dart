class User {
  String email;
  String cellphone;
  String countryCode;

  User(this.email, this.cellphone, this.countryCode);

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        cellphone = json['cellphone'],
        countryCode = json['country_code'];

  Map<String, dynamic> toJson() =>
      {'email': email, 'cellphone': cellphone, 'country_code': countryCode};
}

class TwilioUserWithIdOnly {
  int id;

  TwilioUserWithIdOnly(this.id);

  TwilioUserWithIdOnly.fromJson(Map<String, dynamic> json) : id = json['id'];
}

class TwilioNewUserResponse {
  String message;
  TwilioUserWithIdOnly user;
  bool success;

  TwilioNewUserResponse.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        user = TwilioUserWithIdOnly.fromJson(json['user']),
        success = json['success'];
}

class SmsWithOtpResponse {
  bool success;
  String message;
  String cellphone;

  SmsWithOtpResponse(this.success, this.message, this.cellphone);

  SmsWithOtpResponse.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        message = json['message'],
        cellphone = json['cellphone'];
}
