import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/premium_game_model.dart';
import '../../../models/comment_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import 'play_game_screen.dart';
import '../../../core/services/stripe_service.dart';

class PremiumGameDetailScreen extends StatefulWidget {
  final PremiumGameModel game;

  const PremiumGameDetailScreen({super.key, required this.game});

  @override
  State<PremiumGameDetailScreen> createState() => _PremiumGameDetailScreenState();
}

class _PremiumGameDetailScreenState extends State<PremiumGameDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;
  bool _isDescriptionExpanded = false;
  bool _isProcessingPayment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment(AuthProvider authProvider) async {
    setState(() => _isProcessingPayment = true);

    final pdfUrl = await StripeService.instance.makePayment(
      amount: widget.game.price,
      currency: 'usd',
      email: authProvider.user?.email ?? '',
      name: authProvider.userModel?.displayName ?? authProvider.user?.displayName ?? 'Player',
      gameName: widget.game.title,
    );

    if (pdfUrl != null) {
      // ponytail: Save to both purchased games list and transaction history
      final updated = await authProvider.addPurchasedGame(widget.game.id);
      await authProvider.addTransaction(
        gameId: widget.game.id,
        gameTitle: widget.game.title,
        amount: widget.game.price,
        currency: 'usd',
        pdfUrl: pdfUrl,
      );

      if (updated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase successful! You now own ${widget.game.title}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed or cancelled'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (mounted) setState(() => _isProcessingPayment = false);
  }

  void _showDeleteCommentConfirmation(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Review', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to remove your thoughts on this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.indigoAccent.shade100, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                await Provider.of<CommentProvider>(context, listen: false).deleteComment(commentId);
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Review removed'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final accentColor = Colors.indigoAccent;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final bool isOwned = widget.game.price == 0 || 
        (authProvider.userModel?.purchasedGames.contains(widget.game.id) ?? false);

    return StreamBuilder<List<CommentModel>>(
      stream: commentProvider.getGameComments(widget.game.id),
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];
        
        String ratingText = 'NEW';
        if (comments.isNotEmpty) {
          double sum = 0;
          for (var c in comments) {
            sum += c.rating;
          }
          ratingText = (sum / comments.length).toStringAsFixed(1);
        }

        final bool hasAlreadyCommented = comments.any((c) => c.userId == authProvider.user?.uid);

        return Scaffold(
          backgroundColor: bgColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                stretch: true,
                backgroundColor: bgColor,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'game-premium-${widget.game.id}',
                        child: widget.game.imageUrl.startsWith('assets/')
                            ? Image.asset(widget.game.imageUrl, fit: BoxFit.cover)
                            : Image.network(
                                widget.game.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: accentColor.withOpacity(0.1),
                                  child: Icon(Icons.videogame_asset, size: 80, color: accentColor.withOpacity(0.5)),
                                ),
                              ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              bgColor.withOpacity(0.8),
                              bgColor,
                            ],
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.game.title,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Published by ${widget.game.developer}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star_rounded, color: ratingText == 'NEW' ? Colors.grey : Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  ratingText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildBadge(widget.game.genre, Icons.category_rounded, isDark, accentColor),
                          const SizedBox(width: 12),
                          _buildBadge(widget.game.price == 0 ? 'Free' : '\$${widget.game.price}', Icons.monetization_on_rounded, isDark, accentColor),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessingPayment 
                            ? null 
                            : () {
                                if (isOwned) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayGameScreen(
                                        title: widget.game.title,
                                        gameUrl: widget.game.gameUrl,
                                      ),
                                    ),
                                  );
                                } else {
                                  _handlePayment(authProvider);
                                }
                              },
                          icon: _isProcessingPayment 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(isOwned ? Icons.play_arrow_rounded : Icons.shopping_bag_rounded, size: 28),
                          label: Text(
                            _isProcessingPayment 
                                ? 'Processing...' 
                                : (isOwned ? 'Play Now' : 'Buy Now - \$${widget.game.price}'), 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOwned ? accentColor : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      _buildSectionTitle('Overview', textColor),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.game.description,
                              maxLines: _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withOpacity(0.7),
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                              child: Text(
                                _isDescriptionExpanded ? 'Show Less' : 'Read More',
                                style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionTitle('Community Reviews', textColor),
                      const SizedBox(height: 20),
                      
                      if (!isOwned)
                        _buildLockStatus()
                      else if (!hasAlreadyCommented)
                        _buildCommentForm(authProvider, commentProvider, isDark, accentColor, textColor),
                      
                      const SizedBox(height: 24),
                      if (comments.isEmpty)
                        _buildEmptyComments(textColor)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _CommentCard(comment: comments[index], isDark: isDark, currentUserId: authProvider.user?.uid, provider: commentProvider, accentColor: accentColor, textColor: textColor);
                          },
                        ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.2),
    );
  }

  Widget _buildBadge(String text, IconData icon, bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Purchase this game to share your review with the community.',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No reviews yet. Be the first to share!',
          style: TextStyle(color: textColor.withOpacity(0.4), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCommentForm(AuthProvider auth, CommentProvider provider, bool isDark, Color accentColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Your Rating', style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _userRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    double starRating = _userRating - index;
                    IconData iconData;
                    if (starRating >= 1) {
                      iconData = Icons.star_rounded;
                    } else if (starRating >= 0.5) {
                      iconData = Icons.star_half_rounded;
                    } else {
                      iconData = Icons.star_outline_rounded;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _userRating = (index + 1).toDouble();
                        });
                      },
                      child: Icon(
                        iconData,
                        size: 42,
                        color: starRating > 0 ? Colors.amber : textColor.withOpacity(0.2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: Colors.amber,
                    inactiveTrackColor: Colors.amber.withOpacity(0.1),
                    thumbColor: Colors.white,
                    overlayColor: Colors.amber.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: _userRating,
                    min: 0,
                    max: 5,
                    divisions: 50,
                    onChanged: (value) {
                      setState(() {
                        _userRating = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'What did you think of the game?',
              hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
              filled: true,
              fillColor: isDark ? Colors.black26 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () async {
                if (_commentController.text.trim().isEmpty) return;
                final success = await provider.addComment(
                  gameId: widget.game.id,
                  userId: auth.user!.uid,
                  userName: auth.userModel?.displayName ?? auth.user?.displayName ?? 'Anonymous',
                  userPhotoUrl: auth.userModel?.photoURL ?? auth.user?.photoURL ?? '',
                  comment: _commentController.text.trim(),
                  rating: _userRating,
                );
                if (success) {
                  _commentController.clear();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review posted!'), backgroundColor: Colors.indigo));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: provider.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Text('Post Review', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  final bool isDark;
  final String? currentUserId;
  final CommentProvider provider;
  final Color accentColor;
  final Color textColor;

  const _CommentCard({required this.comment, required this.isDark, this.currentUserId, required this.provider, required this.accentColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool isMyComment = currentUserId == comment.userId;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accentColor.withOpacity(0.1),
                backgroundImage: comment.userPhotoUrl.isNotEmpty ? NetworkImage(comment.userPhotoUrl) : null,
                child: comment.userPhotoUrl.isEmpty ? Icon(Icons.person, size: 20, color: accentColor) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: textColor)),
                    Text(DateFormat('dd MMM yyyy').format(comment.createdAt), style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(comment.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.amber)),
                  ],
                ),
              ),
              if (isMyComment) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Delete Review', style: TextStyle(fontWeight: FontWeight.w900)),
                        content: const Text('Are you sure you want to remove this review?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.deleteComment(comment.id);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment.comment,
            style: TextStyle(fontSize: 14, height: 1.6, color: textColor.withOpacity(0.8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
