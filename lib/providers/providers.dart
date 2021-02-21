import 'package:dovy/general.dart';
import './auth.dart';
export './auth.dart';

final positionProvider = StateProvider<MapPosition>(
  (ref) => null,
);

final systemSelectProvider = StateProvider<SelectState>(
  (ref) => SelectState(
    system: null,
    line: null,
    station: null,
  ),
);

final stationsListProvider = FutureProvider<List>(
  (ref) async {
    final graphQLClient = ref.watch(graphQlProvider);

    final lineId = ref.watch(systemSelectProvider).state.line;

    if (lineId == null) {
      return [];
    }

    final value = await graphQLClient.query(
      QueryOptions(
        documentNode: gql(
          """
              query GetLineStations(\$id: ID!) {
                line(id: \$id) {
                  stations {
                    name
                    id
                  }
                }
              }
        """,
        ),
        variables: {
          "id": lineId,
        },
      ),
    );
    final lines = (value.data["line"]["stations"] as Iterable).toList();
    return lines;
  },
);

final routerProvider = Provider<FluroRouter>(
  (ref) {
    final router = FluroRouter()
      ..define(
        '/',
        handler: Handler(
          handlerFunc: (context, parameters) => MainScreen(),
        ),
      )
      ..define(
        '/login',
        handler: Handler(
          handlerFunc: (context, parameters) => LoginScreen(),
        ),
      )
      ..define(
        '/home',
        handler: Handler(
          handlerFunc: (context, parameters) => HomeScreen(),
        ),
      )
      ..define(
        '/line/:id',
        handler: Handler(
          handlerFunc: (context, parameters) {
            // final args = context.settings.arguments as MyArgumentsDataClass;
            return LineScreen(id: parameters["id"][0]);
          },
        ),
      )
      ..notFoundHandler = Handler(
        handlerFunc: (context, parameters) => NotFoundScreen(),
      );

    return router;
  },
);

final graphQlProvider = Provider<GraphQLClient>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    final token = ref.watch(authTokenProvider)?.data?.value;

    if (token == null || authService == null) {
      return null;
    }

    final HttpLink httpLink = HttpLink(
      uri: 'https://xantiagoma.herokuapp.com/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        return 'Bearer $token';
      },
    );

    final Link link = authLink.concat(httpLink);

    final graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  },
);

final locationDataProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, LatLng>(
  (ref, point) async {
    return await LocationService.getLocation(point);
  },
);

final ipDataProvider = FutureProvider<Map<String, dynamic>>(
  (ref) async {
    return await LocationService.getIpInfo();
  },
);

final strapiServiceProvider = Provider<Strapi>(
  (ref) {
    final token = ref.watch(authTokenProvider)?.data?.value;
    final baseUrl = 'https://xantiagoma.herokuapp.com';
    return Strapi.newClient()
      ..initialize(
        base_url: baseUrl,
        token: token ?? '',
      );
  },
);

final configsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final strapiService = ref.watch(strapiServiceProvider);
  final response = await strapiService.http.get('/configs');
  final configs = response.data;
  return configs;
});

final systemsProvider = FutureProvider<List<System>>(
  (ref) async {
    final strapiService = ref.watch(strapiServiceProvider);
    final systems = (await strapiService.find('systems'))
        .map((e) => System.fromJson(e.data))
        .toList();
    return systems;
  },
);

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final strapiService = ref.watch(strapiServiceProvider);
  final stations = (await strapiService.find('stations'))
      .map((e) => Station.fromJson(e.data))
      .toList();
  return stations;
});

final linesProvider = FutureProvider<List<Line>>((ref) async {
  final strapiService = ref.watch(strapiServiceProvider);
  final lines = (await strapiService.find('lines'))
      .map((e) => Line.fromJson(e.data))
      .toList();
  return lines;
});

final lineProvider =
    FutureProvider.autoDispose.family<Line, String>((ref, id) async {
  final strapiService = ref.watch(strapiServiceProvider);
  final data = (await strapiService.findOne('lines', id)).data;
  return Line.fromJson(data);
});
