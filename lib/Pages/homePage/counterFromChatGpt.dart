import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

class AnimatedCounterPage extends StatefulWidget {
  final int countTo;
  final double fontSize;
  const AnimatedCounterPage({super.key,required this.countTo, required this.fontSize});
  @override
  _AnimatedCounterPageState createState() => _AnimatedCounterPageState();
}

class _AnimatedCounterPageState extends State<AnimatedCounterPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    );

    _animation = IntTween(begin: 1, end: widget.countTo).animate(_controller);
    print("CODE LSKDFJLK");
    print(widget.countTo);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Text(
              _animation.value.toString(),
              style: TextStyle(fontSize: widget.fontSize),
            );
          },
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}