import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Twist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set background color to blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to TextTwist',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), // Set text color to white
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(_createRoute());
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.white, // Set text color to blue
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RephrasePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class RephrasePage extends StatefulWidget {
  @override
  _RephrasePageState createState() => _RephrasePageState();
}

class _RephrasePageState extends State<RephrasePage> {
  final _paragraphController = TextEditingController(); // Controller for the input paragraph
  String? responseText;
  bool _isLoading = false;

  // Initialize the Gemini model
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyCnGLrMegmnfFKs4xzifuE_Lgonz2f9xPQ", // Replace with your actual API key
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set background color to blue
      appBar: AppBar(
        title: const Text('Text Twist', style: TextStyle(color: Colors.blue,fontSize: 20, fontWeight: FontWeight.bold,)), // Set text color to blue
        backgroundColor: Colors.white, // Set app bar color to white
        iconTheme: const IconThemeData(color: Colors.blue), // Set icon color to blue
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [TextField(
              controller: _paragraphController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded edges
                ),
                hintText: 'Enter the paragraph to be rephrased',
                filled: true, // Enables the fillColor
                fillColor: Colors.white, // Sets the background color to white
              ),
              maxLines: 5,
            ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  // Prepare content for Gemini model rephrasing
                  final content = [
                    Content.text(
                        'Rephrase the following paragraph:\n\n'
                            '${_paragraphController.text}\n\n'
                            'Provide the rephrased version.'
                    ),
                  ];

                  // Make request to Gemini model
                  try {
                    final response = await model.generateContent(content);

                    // Handle successful response
                    setState(() {
                      responseText = response?.text;
                      _isLoading = false;
                    });

                    print('API Response: ${response?.text}');
                  } catch (error, stackTrace) {
                    // Handle network or API errors
                    setState(() {
                      responseText = 'Error: $error';
                      _isLoading = false;
                    });

                    print('Error: $error');
                    print('Stack Trace: $stackTrace');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue, backgroundColor: Colors.white, // Set text color to blue
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Rephrase'),
              ),
              const SizedBox(height: 16.0),
              if (responseText != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Rephrased Text:\n\n$responseText',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (responseText != null) {
                    String txt=responseText.toString();
                    Clipboard.setData(ClipboardData(text: txt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white, // Set button color to white
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Copy Text'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
