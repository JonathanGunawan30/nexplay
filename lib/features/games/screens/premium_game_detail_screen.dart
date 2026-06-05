import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/premium_game_model.dart';
import '../../../models/comment_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import 'play_game_screen.dart';

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showDeleteCommentConfirmation(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to remove your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await Provider.of<CommentProvider>(context, listen: false).deleteComment(commentId);
              messenger.showSnackBar(
                const SnackBar(content: Text('Review deleted'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
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
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
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
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade800, child: const Icon(Icons.videogame_asset, color: Colors.white54, size: 80)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, bgColor.withAlpha(200), bgColor],
                            stops: const [0.6, 0.9, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.game.title,
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.game.developer,
                                  style: TextStyle(fontSize: 16, color: secondaryTextColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.amber.withAlpha(40) : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star_rounded, size: 20, color: ratingText == 'NEW' ? Colors.grey : Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  ratingText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: ratingText == 'NEW' 
                                        ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700) 
                                        : (isDark ? Colors.amber.shade400 : Colors.amber.shade800), 
                                    fontSize: 16
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
                          _buildBadge(widget.game.genre, Icons.category_rounded, isDark),
                          const SizedBox(width: 12),
                          _buildBadge(widget.game.price == 0 ? 'Free' : '\$${widget.game.price}', Icons.monetization_on_rounded, isDark),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayGameScreen(
                                  title: widget.game.title,
                                  gameUrl: widget.game.gameUrl,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: const Text('Play Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: Colors.indigo.withAlpha(100),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('About this game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 12),
                      
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.game.description,
                              maxLines: _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade300 : const Color(0xFF475569), height: 1.6),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                              child: Text(
                                _isDescriptionExpanded ? 'Show Less' : 'Read More',
                                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                      
                      Text('Community Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 20),
                      
                      if (!isOwned)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withAlpha(50)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 20),
                              SizedBox(width: 12),
                              Expanded(child: Text('Purchase this game to leave a review.', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w500))),
                            ],
                          ),
                        )
                      else if (!hasAlreadyCommented)
                        _buildCommentForm(authProvider, commentProvider, isDark),
                      
                      const SizedBox(height: 32),

                      if (comments.isEmpty)
                        Center(
                          child: Text('No reviews yet. Be the first!', style: TextStyle(color: secondaryTextColor)),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildCommentCard(comments[index], isDark, authProvider.user?.uid, commentProvider);
                          },
                        ),
                      const SizedBox(height: 100),
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

  Widget _buildCommentForm(AuthProvider auth, CommentProvider provider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Your Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _userRating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _userRating.toInt().toString(),
              onChanged: (v) => setState(() => _userRating = v),
            ),
            Text(_userRating.toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
        TextField(
          controller: _commentController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Share your thoughts about this game...',
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review posted!'), backgroundColor: Colors.green));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: provider.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Post Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard(CommentModel comment, bool isDark, String? currentUserId, CommentProvider provider) {
    final bool isMyComment = currentUserId == comment.userId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: comment.userPhotoUrl.isNotEmpty ? NetworkImage(comment.userPhotoUrl) : null,
                child: comment.userPhotoUrl.isEmpty ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(DateFormat('dd MMM yyyy').format(comment.createdAt), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(comment.rating.toInt().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
                  ],
                ),
              ),
              if (isMyComment) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteCommentConfirmation(context, comment.id),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.comment, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.indigo.withAlpha(40) : Colors.indigo.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.indigo.shade300 : Colors.indigo),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: isDark ? Colors.indigo.shade300 : Colors.indigo, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
