import 'package:flutter/material.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    title: 'Victor Welter',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(child: Text('Victor Welter — Portfólio')),
    ),
  );
}
