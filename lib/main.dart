import 'dart:convert';
import 'package:api_repository/api_repository.dart';
import 'package:audio_service/audio_service.dart';
import 'package:episodes_repository/episodes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogabili_app/handlers/audio_player_handler.dart';
import 'package:jogabili_app/ui/home_page.dart';
import 'blocs/episodes/episodes_bloc.dart';
import 'blocs/player/player_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiRepository = APIRepository();
  EpisodesRepository episodesRepository =
      EpisodesRepository(apiRepository: apiRepository);
  final PodcastAudioHandler audioHandler = await AudioService.init(
      builder: () => PodcastAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.jogabili_app.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ));
  runApp(MyApp(
    apiRepository: apiRepository,
    episodesRepository: episodesRepository,
    audioHandler: audioHandler,
  ));
}

class MyApp extends StatelessWidget {
  MyApp(
      {Key? key,
      required this.apiRepository,
      required this.episodesRepository,
      required this.audioHandler});
  final APIRepository apiRepository;
  final EpisodesRepository episodesRepository;
  final PodcastAudioHandler audioHandler;

  final Episode episode = Episode.fromJson(jsonDecode("""
  {
    "title": "DASH #130: The Last of Us Part II",
    "description": "Batemos um longo papo sobre cada momento, personagem, reviravolta e interpretação sobre a sofrida, inesperada e por vezes esperançosa jornada do mais premiado e controverso jogo de 2020. Com Caio Corraini, Ricardo Dias, Mikannn e Vanessa Raposo.",
    "subTitle": "Apenas na fraqueza poderei encontrar minha verdadeira força.",
    "imageUrl": "https://640272.smushcdn.com/923689/wp-content/uploads/2021/06/dash130-capa-780x470.jpg?lossy=0&strip=1&webp=0",
    "pubDate": "07/06/2021",
    "type": "games"
  }"""));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => apiRepository),
          RepositoryProvider(create: (_) => episodesRepository)
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => EpisodesBloc(
                    episodesRepository: context.read<EpisodesRepository>())),
            BlocProvider(create: (context) => PlayerBloc(audioHandler))
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.yellow,
            ),
            home: HomePage(),
          ),
        ));
  }
}
