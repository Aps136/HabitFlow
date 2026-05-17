import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/quote_service.dart';

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});
  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  late Map<String, String> _quote;

  @override
  void initState() {
    super.initState();
    _quote = QuoteService.getDailyQuote();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.85),
            AppTheme.accent.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Daily Inspiration',
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _quote = QuoteService.getRandomQuote()),
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.white70, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${_quote['text']}"',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Author — use Align + flexible text, never overflows
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  '— ${_quote['author']}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}