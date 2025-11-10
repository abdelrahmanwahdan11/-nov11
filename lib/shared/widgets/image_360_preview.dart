import 'package:flutter/material.dart';

class Image360Preview extends StatefulWidget {
  const Image360Preview({super.key, required this.frames});

  final List<String> frames;

  @override
  State<Image360Preview> createState() => _Image360PreviewState();
}

class _Image360PreviewState extends State<Image360Preview> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 1) {
          setState(() {
            _index = (_index - 1) % widget.frames.length;
          });
        } else if (details.delta.dx < -1) {
          setState(() {
            _index = (_index + 1) % widget.frames.length;
          });
        }
        if (_controller.hasClients) {
          _controller.jumpToPage(_index);
        }
      },
      child: SizedBox(
        height: 280,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.frames.length,
          itemBuilder: (context, index) {
            final url = widget.frames[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }
}
