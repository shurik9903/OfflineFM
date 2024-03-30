import 'package:flutter/material.dart';
import 'package:flutter_offline_fm/data/radio_data.dart';

class SliderRadioContainer extends StatefulWidget {
  const SliderRadioContainer(
      {super.key,
      this.duration,
      this.position,
      required this.onChangedPosition,
      required this.record});

  final Duration? duration;
  final Duration? position;
  final Function(Duration) onChangedPosition;
  final RecordData record;

  @override
  State<SliderRadioContainer> createState() => _SliderRadioContainerState();
}

class _SliderRadioContainerState extends State<SliderRadioContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Slider(
            activeColor: Colors.white,
            inactiveColor: Colors.black,
            min: 0,
            max: widget.duration?.inSeconds.toDouble() ??
                widget.position?.inSeconds.toDouble() ??
                0,
            onChanged: (value) async {
              if (widget.duration == null) return;

              final position = Duration(seconds: value.toInt());

              await widget.onChangedPosition(position);
            },
            value: widget.position?.inSeconds.toDouble() ?? 0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.position != null
                          ? formatTime(widget.position!)
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.duration != null && widget.position != null
                          ? '/${formatTime(widget.duration! - widget.position!)}'
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                RecordInfoContainer(
                  record: widget.record,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecordInfoContainer extends StatefulWidget {
  const RecordInfoContainer({
    super.key,
    required this.record,
  });

  final RecordData record;

  @override
  State<RecordInfoContainer> createState() => _RecordInfoContainerState();
}

class _RecordInfoContainerState extends State<RecordInfoContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 5),
            decoration: const BoxDecoration(
                border: BorderDirectional(
                    end: BorderSide(
              width: 2,
            ))),
            child: Icon(
              Icons.radio_button_checked_rounded,
              color: widget.record.isRecord ? Colors.red : Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(
                border: BorderDirectional(
                    end: BorderSide(
              width: 2,
            ))),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    formatTime(widget.record.time),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              widget.record.bytes.getSize(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
