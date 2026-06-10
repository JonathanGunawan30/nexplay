import 'package:flutter/material.dart';
import '../../../models/premium_game_model.dart';

class PremiumGameProvider with ChangeNotifier {
  List<PremiumGameModel> _games = [];
  bool _isLoading = false;

  List<PremiumGameModel> get games => _games;
  bool get isLoading => _isLoading;

  PremiumGameProvider() {
    loadGames();
  }

  final List<PremiumGameModel> _cloudLibrary = [
    const PremiumGameModel(
      id: 'cloud_mc',
      title: 'Minecraft Classic',
      developer: 'Mojang',
      genre: 'Sandbox',
      description: 'The legendary Minecraft! Build, explore, and create in your own infinite world using only basic blocks. This is a faithful web recreation of the original 2009 creative mode that started a global phenomenon. No monsters, no survival pressure—just pure, unadulterated creativity and the freedom to shape the landscape exactly as you imagine it.\n\nInvite your friends to your world and collaborate on massive structures, or simply wander through the blocky terrain and find inspiration in simplicity. Minecraft Classic is a testament to the power of imagination, providing a peaceful yet deeply engaging sandbox experience that remains as charming today as it was over a decade ago.',
      imageUrl: 'assets/games/minecraft.jpg',
      price: 9.99,
      rating: 4.9,
      gameUrl: 'https://classic.minecraft.net/',
    ),
    const PremiumGameModel(
      id: 'cloud_breaklock',
      title: 'Break Lock',
      developer: 'Maxwellito',
      genre: 'Puzzle',
      description: 'Break Lock is a premium mental challenge that tests your logical deduction and pattern recognition skills. Your objective is simple but profound: find the hidden pattern to unlock the mechanism. Inspired by the pattern locks found on modern smartphones, this game elevates the concept into a sophisticated and minimalist puzzle experience.\n\nEvery attempt provides you with vital feedback, allowing you to narrow down the possibilities through careful analysis. With multiple difficulty levels and a clean, focused interface, Break Lock is the perfect game for players who enjoy "training" their brain. It is satisfying, challenging, and offers a deep sense of accomplishment with every successful breach.',
      imageUrl: 'assets/games/breaklock.png',
      price: 0.0,
      rating: 4.5,
      gameUrl: 'https://maxwellito.github.io/breaklock/',
    ),
    const PremiumGameModel(
      id: 'cloud_tetris',
      title: 'Classic Tetris',
      developer: 'Chvin',
      genre: 'Puzzle',
      description: 'Step into the timeless world of Classic Tetris, the ultimate tile-matching puzzle game that defined an entire generation of gaming. Arrange the falling geometric shapes, known as Tetriminos, to create solid horizontal lines and clear them from the board. As you clear more lines, the speed increases, pushing your focus and reaction time to their absolute limits.\n\nThis React-powered version delivers a pixel-perfect, stable experience that captures the "easy to learn, hard to master" philosophy that made Tetris a global icon. Whether you are a veteran player or a newcomer, the satisfying loop of strategic placement and high-pressure decision-making remains as addictive as ever. Can you achieve the legendary Tetris and dominate the scoreboard?',
      imageUrl: 'assets/games/tetris.png',
      price: 0.0,
      rating: 4.8,
      gameUrl: 'https://chvin.github.io/react-tetris/',
    ),
  ];

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _games = List.from(premiumGamesList); 
    _games.addAll(_cloudLibrary);
    
    _isLoading = false;
    notifyListeners();
  }
}
