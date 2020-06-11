part of smashlibs;

/// Class to help out with some common netwrok stuff.
class NetworkHelper {
  /// Get a new [Dio] instance, if necessary configured.
  static Dio getNewDioInstance() {
    bool allowSelfCert = GpPreferences()
        .getBooleanSync(KEY_GSS_SERVER_ALLOW_SELFCERTIFICATE, true);
    Dio dio = Dio();
    if (allowSelfCert) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    return dio;
  }
}
