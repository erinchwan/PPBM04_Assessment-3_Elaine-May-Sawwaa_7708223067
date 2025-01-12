import 'package:flutter/material.dart';

enum ConversionType { temperature, currency, weight }

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({Key? key}) : super(key: key);

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  ConversionType? _selectedConversion;
  String _input = "";
  String _result = "";

  void _onNumberPress(String value) {
    setState(() {
      _input += value; // Append the pressed number to _input
    });
  }

  void _onClear() {
    setState(() {
      _input = ""; // Clear the input
      _result = ""; // Reset the result
    });
  }

  void _onDelete() {
    setState(() {
      if (_input.isNotEmpty) {
        _input =
            _input.substring(0, _input.length - 1); // Remove last character
      }
    });
  }

  void _convert() {
    if (_input.isEmpty || _selectedConversion == null) {
      setState(() {
        _result = "Please select a conversion type and enter a value.";
      });
      return;
    }

    final inputNumber = double.tryParse(_input);
    if (inputNumber == null) {
      setState(() {
        _result = "Invalid number format.";
      });
      return;
    }

    setState(() {
      switch (_selectedConversion) {
        case ConversionType.temperature:
          _result = "$inputNumber°C = ${(inputNumber * 9 / 5) + 32}°F";
          break;
        case ConversionType.currency:
          _result =
              "IDR $inputNumber = USD ${(inputNumber / 15000).toStringAsFixed(2)}";
          break;
        case ConversionType.weight:
          _result =
              "$inputNumber lbs = ${(inputNumber * 0.453592).toStringAsFixed(2)} kg";
          break;
        default:
          _result = "Please select a conversion type.";
      }
    });
  }

  Widget _buildKey(String label, {Color? color, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () => _onNumberPress(label),
      child: Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversion Calculator"),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.black,
            width: double.infinity,
            child: Column(
              children: [
                DropdownButton<ConversionType>(
                  dropdownColor: Colors.grey[900],
                  value: _selectedConversion,
                  hint: const Text(
                    "Select Conversion Type",
                    style: TextStyle(color: Colors.white),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ConversionType.temperature,
                      child: Text("Temperature (°C to °F)",
                          style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: ConversionType.currency,
                      child: Text("Currency (IDR to USD)",
                          style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: ConversionType.weight,
                      child: Text("Weight (lbs to kg)",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedConversion = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _input,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  _result,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black,
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildKey("7"),
                  _buildKey("8"),
                  _buildKey("9"),
                  _buildKey("DEL",
                      color: Colors.red[800], onPressed: _onDelete),
                  _buildKey("4"),
                  _buildKey("5"),
                  _buildKey("6"),
                  _buildKey("C", color: Colors.red[600], onPressed: _onClear),
                  _buildKey("1"),
                  _buildKey("2"),
                  _buildKey("3"),
                  GestureDetector(
                    onTap: _convert,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "=",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  _buildKey("0", color: Colors.grey[850]),
                  _buildKey("."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
