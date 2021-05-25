class IdallUserInfo {
  String sub;
  String preferredUsername;
  String phoneNumber;
  String phoneNumberVerified;
  String name;
  String givenName;
  String familyName;
  String gender;

  IdallUserInfo(
      {this.sub,
        this.preferredUsername,
        this.phoneNumber,
        this.phoneNumberVerified,
        this.name,
        this.givenName,
        this.familyName,
        this.gender});

  IdallUserInfo.fromJson(Map<String, dynamic> json) {
    sub = json['sub'];
    preferredUsername = json['preferred_username'];
    phoneNumber = json['phone_number'];
    phoneNumberVerified = json['phone_number_verified'];
    name = json['name'];
    givenName = json['given_name'];
    familyName = json['family_name'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sub'] = this.sub;
    data['preferred_username'] = this.preferredUsername;
    data['phone_number'] = this.phoneNumber;
    data['phone_number_verified'] = this.phoneNumberVerified;
    data['name'] = this.name;
    data['given_name'] = this.givenName;
    data['family_name'] = this.familyName;
    data['gender'] = this.gender;
    return data;
  }
}
