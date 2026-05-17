import 'dart:math';

class QuoteService {
  static const List<Map<String, String>> _quotes = [
    {'text': 'We are what we repeatedly do. Excellence is not an act, but a habit.', 'author': 'Aristotle'},
    {'text': 'Motivation gets you started. Habit keeps you going.', 'author': 'Jim Ryun'},
    {'text': 'Small daily improvements over time lead to stunning results.', 'author': 'Robin Sharma'},
    {'text': 'The secret of your future is hidden in your daily routine.', 'author': 'Mike Murdock'},
    {'text': 'You do not rise to the level of your goals. You fall to the level of your systems.', 'author': 'James Clear'},
    {'text': 'Habits are the compound interest of self-improvement.', 'author': 'James Clear'},
    {'text': 'Success is the sum of small efforts repeated day in and day out.', 'author': 'Robert Collier'},
    {'text': 'Your net worth to the world is usually determined by what remains after your bad habits are subtracted from your good ones.', 'author': 'Benjamin Franklin'},
    {'text': 'First forget inspiration. Habit is more dependable.', 'author': 'Octavia Butler'},
    {'text': 'The chains of habit are too light to be felt until they are too heavy to be broken.', 'author': 'Warren Buffett'},
    {'text': 'A habit cannot be tossed out the window; it must be coaxed down the stairs a step at a time.', 'author': 'Mark Twain'},
    {'text': 'In essence, if we want to direct our lives, we must take control of our consistent actions.', 'author': 'Tony Robbins'},
    {'text': 'Depending on what they are, our habits will either make us or break us.', 'author': 'Denis Waitley'},
    {'text': 'You\'ll never change your life until you change something you do daily.', 'author': 'John C. Maxwell'},
    {'text': 'Discipline is choosing between what you want now and what you want most.', 'author': 'Abraham Lincoln'},
  ];

  static Map<String, String> getDailyQuote() {
    // Same quote all day, changes daily
    final dayIndex = DateTime.now().day % _quotes.length;
    return _quotes[dayIndex];
  }

  static Map<String, String> getRandomQuote() {
    return _quotes[Random().nextInt(_quotes.length)];
  }
}