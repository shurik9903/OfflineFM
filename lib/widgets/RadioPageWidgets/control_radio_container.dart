import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';
import 'package:flutter_offline_fm/widgets/RadioPageWidgets/player_radio_container.dart';
import 'package:flutter_offline_fm/widgets/RadioPageWidgets/slider_radio_container.dart';

class ControlRadioContainer extends StatefulWidget {
  const ControlRadioContainer(
      {super.key,
      this.duration,
      this.position,
      required this.recordData,
      required this.onChangedPosition,
      required this.prevRadio,
      required this.nextRadio,
      required this.stop,
      required this.play,
      required this.isPlaying});

  final Duration? duration;
  final Duration? position;
  final Function(Duration) onChangedPosition;
  final RecordData recordData;

  final Function prevRadio;
  final Function nextRadio;
  final Function stop;
  final Function play;

  final bool isPlaying;

  @override
  State<ControlRadioContainer> createState() => _ControlRadioContainerState();
}

class _ControlRadioContainerState extends State<ControlRadioContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerRadioContainer(
          isPlaying: widget.isPlaying,
          nextRadio: widget.nextRadio,
          play: widget.play,
          stop: widget.stop,
          prevRadio: widget.prevRadio,
        ),
        SliderRadioContainer(
          duration: widget.duration,
          position: widget.position,
          onChangedPosition: widget.onChangedPosition,
          record: widget.recordData,
        ),
      ],
    );
  }
}
