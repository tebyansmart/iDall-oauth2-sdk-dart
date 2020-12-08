class OpenIdConfigModel  {
  String issuer;
  String jwksUri;
  String authorizationEndpoint;
  String tokenEndpoint;
  String userinfoEndpoint;
  String endSessionEndpoint;
  String checkSessionIframe;
  String revocationEndpoint;
  String introspectionEndpoint;
  String deviceAuthorizationEndpoint;
  bool frontchannelLogoutSupported;
  bool frontchannelLogoutSessionSupported;
  bool backchannelLogoutSupported;
  bool backchannelLogoutSessionSupported;
  List<String> scopesSupported;
  List<String> claimsSupported;
  List<String> grantTypesSupported;
  List<String> responseTypesSupported;
  List<String> responseModesSupported;
  List<String> tokenEndpointAuthMethodsSupported;
  List<String> idTokenSigningAlgValuesSupported;
  List<String> subjectTypesSupported;
  List<String> codeChallengeMethodsSupported;
  bool requestParameterSupported;

  OpenIdConfigModel(
      {this.issuer,
      this.jwksUri,
      this.authorizationEndpoint,
      this.tokenEndpoint,
      this.userinfoEndpoint,
      this.endSessionEndpoint,
      this.checkSessionIframe,
      this.revocationEndpoint,
      this.introspectionEndpoint,
      this.deviceAuthorizationEndpoint,
      this.frontchannelLogoutSupported,
      this.frontchannelLogoutSessionSupported,
      this.backchannelLogoutSupported,
      this.backchannelLogoutSessionSupported,
      this.scopesSupported,
      this.claimsSupported,
      this.grantTypesSupported,
      this.responseTypesSupported,
      this.responseModesSupported,
      this.tokenEndpointAuthMethodsSupported,
      this.idTokenSigningAlgValuesSupported,
      this.subjectTypesSupported,
      this.codeChallengeMethodsSupported,
      this.requestParameterSupported});

  OpenIdConfigModel.fromJson(Map<String, dynamic> json) {
    issuer = json['issuer'];
    jwksUri = json['jwks_uri'];
    authorizationEndpoint = json['authorization_endpoint'];
    tokenEndpoint = json['token_endpoint'];
    userinfoEndpoint = json['userinfo_endpoint'];
    endSessionEndpoint = json['end_session_endpoint'];
    checkSessionIframe = json['check_session_iframe'];
    revocationEndpoint = json['revocation_endpoint'];
    introspectionEndpoint = json['introspection_endpoint'];
    deviceAuthorizationEndpoint = json['device_authorization_endpoint'];
    frontchannelLogoutSupported = json['frontchannel_logout_supported'];
    frontchannelLogoutSessionSupported =
    json['frontchannel_logout_session_supported'];
    backchannelLogoutSupported = json['backchannel_logout_supported'];
    backchannelLogoutSessionSupported =
    json['backchannel_logout_session_supported'];
    scopesSupported = json['scopes_supported'].cast<String>();
    claimsSupported = json['claims_supported'].cast<String>();
    grantTypesSupported = json['grant_types_supported'].cast<String>();
    responseTypesSupported = json['response_types_supported'].cast<String>();
    responseModesSupported = json['response_modes_supported'].cast<String>();
    tokenEndpointAuthMethodsSupported =
        json['token_endpoint_auth_methods_supported'].cast<String>();
    idTokenSigningAlgValuesSupported =
        json['id_token_signing_alg_values_supported'].cast<String>();
    subjectTypesSupported = json['subject_types_supported'].cast<String>();
    codeChallengeMethodsSupported =
        json['code_challenge_methods_supported'].cast<String>();
    requestParameterSupported = json['request_parameter_supported'];
  }



}
