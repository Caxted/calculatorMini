import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter (blur)
import 'package:math_expressions/math_expressions.dart' as mathExp; // For math parsing & evaluation

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Stores user input and result
  String userInput = "";
  String result = "0";

  // Theme mode toggle
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ===== BACKGROUND GRADIENT (Exact Colors) =====
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                const Color(0xFF0D1117), // Dark navy from ref
                const Color(0xFF1C2128)  // Slightly lighter navy
              ]
                  : [
                const Color(0xFFF2F6FB), // Light grayish-blue from ref
                const Color(0xFFDCE6F2)  // Slightly darker blue-gray
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // ===== MAIN SCAFFOLD =====
        Scaffold(
          backgroundColor: Colors.transparent, // Let gradient show through
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ===== DISPLAY AREA =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Theme toggle icon (top right)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          onPressed: () =>
                              setState(() => isDarkMode = !isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // User input text (smaller)
                      Text(
                        userInput,
                        style: TextStyle(
                          fontSize: 28,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Result text (large & bold)
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? const Color(0xFF00FFB3) // Neon green from ref
                              : const Color(0xFF0066CC), // Bold blue from ref
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== BUTTON AREA =====
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      buildButtonRow(['C', 'DEL', '%', '/']),
                      buildButtonRow(['7', '8', '9', '*']),
                      buildButtonRow(['4', '5', '6', '-']),
                      buildButtonRow(['1', '2', '3', '+']),
                      buildLastRow(), // Last row with big zero and '='
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== Creates a Row of Buttons =====
  Widget buildButtonRow(List<String> texts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: texts
          .map((text) => buildGlassButton(
        text,
        isOperator: ['/', '*', '-', '+', '%'].contains(text),
        isEqual: text == '=',
      ))
          .toList(),
    );
  }

  // ===== Creates the Last Row (Big Zero + Dot + =) =====
  Widget buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildGlassButton('0', flex: 2), // Wider zero button
        buildGlassButton('.'),
        buildGlassButton('=', isEqual: true),
      ],
    );
  }

  // ===== Glassmorphism Button =====
  Widget buildGlassButton(String text,
      {bool isOperator = false, bool isEqual = false, int flex = 1}) {
    // Background colors for glass effect (exact opacities from ref)
    final bgColor = isDarkMode
        ? Colors.white.withOpacity(0.05) // Dark mode glass
        : Colors.white.withOpacity(0.35); // Light mode glass
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.25);

    // Text colors
    final textColor = isOperator
        ? (isDarkMode ? const Color(0xFF61AFFF) : const Color(0xFF0055AA)) // Operator blue
        : (isDarkMode ? Colors.white : Colors.black);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18), // Rounded corners from ref
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Glass blur
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isEqual
                    ? (isDarkMode
                    ? const Color(0xFF2D7DFF).withOpacity(0.9) // Bright blue '=' in dark
                    : const Color(0xFF0066CC).withOpacity(0.9)) // Blue '=' in light
                    : bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onButtonClick(text),
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        isEqual ? FontWeight.bold : FontWeight.w500,
                        color: isEqual ? Colors.white : textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== Logic for Button Click =====
  void onButtonClick(String value) {
    setState(() {
      if (value == "C") {
        // Clear all
        userInput = "";
        result = "0";
      } else if (value == "DEL") {
        // Delete last char
        if (userInput.isNotEmpty) {
          userInput = userInput.substring(0, userInput.length - 1);
        }
      } else if (value == "=") {
        // Calculate
        result = evaluateExpression(userInput);
      } else {
        // Append to input
        userInput += value;
      }
    });
  }

  // ===== Evaluate the Math Expression =====
  String evaluateExpression(String expression) {
    try {
      // Convert percentage symbol to division
      expression = expression.replaceAll('%', '/100');

      // Parse and evaluate using math_expressions
      mathExp.Parser p = mathExp.Parser();
      mathExp.Expression exp = p.parse(expression);
      mathExp.ContextModel cm = mathExp.ContextModel();
      double eval = exp.evaluate(mathExp.EvaluationType.REAL, cm);

      return eval.toString();
    } catch (e) {
      return "Error";
    }
  }
}
