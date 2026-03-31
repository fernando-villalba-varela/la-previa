import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drinkaholic/core/models/question_generator.dart';
import 'package:drinkaholic/core/presentation/components/drinkaholic_button.dart';
import 'package:drinkaholic/core/presentation/components/drinkaholic_card.dart';
import 'package:drinkaholic/core/presentation/components/neon_background_layer.dart';
import 'package:drinkaholic/core/presentation/components/neon_header.dart';

class TestQuestionsScreen extends StatefulWidget {
  const TestQuestionsScreen({super.key});

  @override
  State<TestQuestionsScreen> createState() => _TestQuestionsScreenState();
}

class _TestQuestionsScreenState extends State<TestQuestionsScreen> {
  String _currentQuestion = 'Presiona el botón para generar una pregunta';
  String _currentCategory = '';
  List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await QuestionGenerator.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _generateRandomQuestion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final question = await QuestionGenerator.generateRandomQuestion();
      setState(() {
        _currentQuestion = question.question;
        _currentCategory = question.categoria;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentQuestion = 'Error: $e';
        _currentCategory = 'Error';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateQuestionByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final question = await QuestionGenerator.generateQuestionByCategory(category);
      setState(() {
        _currentQuestion = question.question;
        _currentCategory = question.categoria;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentQuestion = 'Error: $e';
        _currentCategory = 'Error';
        _isLoading = false;
      });
    }
  }

  void _testProbabilities() {
    QuestionGenerator.testDrinkProbabilities(1000);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Revisa la consola para ver los resultados del test de probabilidades',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2A4A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A),
      body: NeonBackgroundLayer(
        child: SafeArea(
          child: Column(
            children: [
              NeonHeader(
                title: 'TEST DE PREGUNTAS',
                themeColor: const Color(0xFFFF7B7B),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Pregunta actual
                      DrinkaholicCard(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_currentCategory.isNotEmpty && _currentCategory != 'Error')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7B7B).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFF7B7B).withOpacity(0.3)),
                                ),
                                child: Text(
                                  _currentCategory,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFF7B7B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            _isLoading
                                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7B7B)))
                                : Text(
                                    _currentQuestion,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      // Botón generar pregunta aleatoria
                      SizedBox(
                        width: double.infinity,
                        child: DrinkaholicButton(
                          label: 'Generar Pregunta Aleatoria',
                          icon: Icons.shuffle,
                          onPressed: _isLoading ? null : _generateRandomQuestion,
                          variant: DrinkaholicButtonVariant.primary,
                          height: 56,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón test de probabilidades
                      SizedBox(
                        width: double.infinity,
                        child: DrinkaholicButton(
                          label: 'Test Probabilidades',
                          icon: Icons.analytics_outlined,
                          onPressed: _testProbabilities,
                          variant: DrinkaholicButtonVariant.secondary,
                          height: 52,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Categorías
                      Text(
                        'GENERAR POR CATEGORÍA:',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return DrinkaholicButton(
                              label: category,
                              onPressed: _isLoading ? null : () => _generateQuestionByCategory(category),
                              variant: DrinkaholicButtonVariant.outline,
                              fullWidth: true,
                              height: 44,
                              borderRadius: 16,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
