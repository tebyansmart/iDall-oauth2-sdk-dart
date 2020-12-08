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
    final data = <String, dynamic>{};
    data['id_token'] = idToken;
    data['access_token'] = accessToken;
    data['expires_in'] = expiresIn;
    data['token_type'] = tokenType;
    data['refresh_token'] = refreshToken;
    data['scope'] = scope;
    return data;
  }
}
