const String apiKey =
    "5b3ce3597851110001cf6248420adc5893254ce39caebf313f1403ce";
const String baseURL =
    "https://api.openrouteservice.org/v2/directions/driving-car";

getRouteURL(String startPoint, String endPoint) {
  return Uri.parse('$baseURL?api_key=$apiKey&start=$startPoint&end=$endPoint');
}
