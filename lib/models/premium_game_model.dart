class PremiumGameModel {
  final String id;
  final String title;
  final String developer;
  final String genre;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final String gameUrl;

  const PremiumGameModel({
    required this.id,
    required this.title,
    required this.developer,
    required this.genre,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.gameUrl,
  });
}

final List<PremiumGameModel> premiumGamesList = [
  const PremiumGameModel(
    id: 'game_002',
    title: 'Hextris',
    developer: 'Hextris Team',
    genre: 'Arcade',
    description: 'Hextris is a fast-paced puzzle game inspired by Tetris. The goal of the game is to stop blocks from leaving the inside of the outer gray hexagon. You must rotate the hexagon to capture the falling blocks and match three or more blocks of the same color to make them disappear.\n\nAs the game progresses, the blocks will fall faster and the colors will become more varied, requiring quick reflexes and strategic thinking. Master the rotation and aim for the highest score in this addictive and minimalist arcade challenge that has captured millions of players worldwide.',
    imageUrl: 'assets/games/hextris.png',
    price: 0.0,
    rating: 4.7,
    gameUrl: 'https://hextris.io/',
  ),
  const PremiumGameModel(
    id: 'game_003',
    title: 'Clumsy Bird',
    developer: 'Ellison Leao',
    genre: 'Arcade',
    description: 'Clumsy Bird is a vibrant and challenging arcade game that pays homage to the classic bird-flying genre. Take control of a clumsy but determined bird as it navigates through a series of increasingly difficult pipe obstacles. Every tap of your screen sends the bird upward, fighting against gravity to find the perfect path through the gaps.\n\nFocus and timing are essential to survive this endless journey. With its colorful graphics and simple yet punishing gameplay loop, Clumsy Bird offers a "just one more try" experience that is perfect for short gaming sessions or long-distance travel. How many pipes can you clear before your wings give out?',
    imageUrl: 'assets/games/clumsybird.png',
    price: 0.0,
    rating: 4.5,
    gameUrl: 'https://ellisonleao.github.io/clumsy-bird/',
  ),
  const PremiumGameModel(
    id: 'game_004',
    title: 'Dino Run',
    developer: 'Wayou',
    genre: 'Casual',
    description: 'Experience the ultimate retro runner with Dino Run, a faithful recreation of the iconic browser-based dinosaur adventure. Leap over cacti, dodge flying pterodactyls, and sprint through a prehistoric wasteland in a desperate bid for survival. The minimalist pixel art and smooth animations bring this legendary 8-bit style experience to life on your device.\n\nWhether you are offline or just looking for a quick nostalgia trip, Dino Run provides endless entertainment with its simple one-tap controls. Test your limits as the speed increases and the environment becomes more treacherous. It is not just a game; it is a battle against extinction in its purest arcade form.',
    imageUrl: 'assets/games/dinorun.png',
    price: 4.99,
    rating: 4.8,
    gameUrl: 'https://wayou.github.io/t-rex-runner/',
  ),
];
