class RefreshToken {
  String idToken;
  String accessToken;
  int expiresIn;
  String tokenType;
  String refreshToken;
  String scope;

  RefreshToken(
      {this.idToken,
      this.accessToken,
      this.expiresIn,
      this.tokenType,
      this.refreshToken,
      this.scope});

  RefreshToken.fromJson(Map<String, dynamic> json) {
    idToken = json['id_token'];
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    tokenType = json['token_type'];
    refreshToken = json['refresh_token'];
    scope = json['scope'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_token'] = this.idToken;
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['token_type'] = this.tokenType;
    data['refresh_token'] = this.refreshToken;
    data['scope'] = this.scope;
    return data;
  }
}
