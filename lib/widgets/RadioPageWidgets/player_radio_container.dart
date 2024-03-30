import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/services/music_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PlayerRadioContainer extends StatefulWidget {
  const PlayerRadioContainer(
      {super.key,
      required this.prevRadio,
      required this.nextRadio,
      required this.stop,
      required this.play,
      required this.isPlaying});

  final Function prevRadio;
  final Function nextRadio;
  final Function stop;
  final Function play;

  final bool isPlaying;

  @override
  State<PlayerRadioContainer> createState() => _PlayerRadioContainerState();
}

class _PlayerRadioContainerState extends State<PlayerRadioContainer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PrevButton(
          toPrev: widget.prevRadio,
        ),
        PlayButton(
          isPlaying: widget.isPlaying,
          toPlay: widget.play,
          toStop: widget.stop,
        ),
        NextButton(
          toNext: widget.nextRadio,
        ),
      ],
    );
  }
}

class PlayButton extends StatefulWidget {
  const PlayButton(
      {super.key, this.toPlay, this.toStop, this.isPlaying, this.color});

  final bool? isPlaying;
  final Function? toPlay;
  final Function? toStop;
  final Color? color;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool _isLoad = false;
  bool _isPlaying = false;

  @override
  void initState() {
    _isPlaying = widget.isPlaying ?? false;
    super.initState();
  }

  play() async {
    setState(() {
      _isLoad = true;
    });

    if (!(widget.isPlaying ?? _isPlaying)) {
      if (await widget.toPlay != null) {
        if (await widget.toPlay!()) {
          setState(() {
            _isPlaying = true;
          });
        }
      }
    } else {
      if (await widget.toStop != null) {
        if (await widget.toStop!()) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    }

    setState(() {
      _isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoad
        ? FittedBox(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Center(
                  child: LoadingAnimationWidget.beat(
                color: widget.color ?? Colors.black,
                size: 80,
              )),
            ),
          )
        : FittedBox(
            child: IconButton(
              iconSize: 100,
              onPressed: play,
              icon: Icon(
                  widget.isPlaying ?? _isPlaying
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  color: widget.color ?? Colors.black),
            ),
          );
  }
}

class PrevButton extends StatefulWidget {
  const PrevButton({super.key, this.toPrev, this.color});

  final Function? toPrev;
  final Color? color;

  @override
  State<PrevButton> createState() => _PrevButtonState();
}

class _PrevButtonState extends State<PrevButton> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: IconButton(
        iconSize: 100,
        onPressed: () => {if (widget.toPrev != null) widget.toPrev!()},
        icon: Icon(
          Icons.skip_previous_rounded,
          color: widget.color ?? Colors.black,
        ),
      ),
    );
  }
}

class NextButton extends StatefulWidget {
  const NextButton({super.key, this.toNext, this.color});

  final Function? toNext;
  final Color? color;

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: IconButton(
        iconSize: 100,
        onPressed: () => {if (widget.toNext != null) widget.toNext!()},
        icon:
            Icon(Icons.skip_next_rounded, color: widget.color ?? Colors.black),
      ),
    );
  }
}
