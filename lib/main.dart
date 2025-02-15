import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/track.dart';
import 'player.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Player(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();
    final player = Provider.of<Player>(context, listen: false);
    player.setPlaylist([
      Track(
        title: 'Повод',
        artist: 'Morgenshtern',
        url: 'https://dl2.mp3party.net/download/11259754',
        coverUrl:
            'https://avatars.yandex.net/get-music-content/14369544/52169222.a.35411305-1/100x100',
      ),
      Track(
        title: 'Song 2',
        artist: 'Artist 2',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        coverUrl: 'https://placehold.co/150/png',
      ),
      Track(
        title: 'Song 3',
        artist: 'Artist 3',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        coverUrl: 'https://placehold.co/150/png',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<Player>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: player.playlist.length,
              itemBuilder: (context, index) {
                final track = player.playlist[index];
                return ListTile(
                  leading: Image.network(
                    track.coverUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(track.title),
                  subtitle: Text(track.artist),
                  tileColor: player.currentTrackIndex == index
                      ? Colors.deepPurple.withOpacity(0.1)
                      : null,
                  onTap: () {
                    if (player.currentTrackIndex == index) {
                      // Если трек уже играет, ставим на паузу или воспроизводим
                      if (player.isPlaying) {
                        player.pause();
                      } else {
                        player.play();
                      }
                    } else {
                      // Иначе воспроизводим выбранный трек
                      player.playTrack(index);
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.network(
                  player.playlist[player.currentTrackIndex].coverUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  player.playlist[player.currentTrackIndex].title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  player.playlist[player.currentTrackIndex].artist,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final totalDuration = player.totalDuration;

                    // Показываем ползунок только если длительность трека больше нуля
                    if (totalDuration.inSeconds > 0) {
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            max: totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              player.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(totalDuration),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Если длительность трека еще не определена, скрываем ползунок
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: player.previous,
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (player.isPlaying) {
                          player.pause();
                        } else {
                          player.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: player.next,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Кнопка для отключения звука и слайдер громкости
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        player.isMuted ? Icons.volume_off : Icons.volume_up,
                      ),
                      onPressed: player.toggleMute,
                    ),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: player.volume,
                        onChanged: (value) {
                          player.setVolume(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}