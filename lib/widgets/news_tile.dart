import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:news_apps/models/article_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsTile extends StatefulWidget {
  const NewsTile({super.key, required this.articleModel, required this.index});

  final ArticleModel articleModel;
  final int index;

  @override
  State<NewsTile> createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openArticle(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with shimmer loading
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.articleModel.image ?? 
                      "https://static.wixstatic.com/media/cf074f_5205c185b42f4273adb527b0bf54c9df.png",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 200,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  // Source badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.articleModel.source.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.articleModel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  // Description
                  if (widget.articleModel.description != null)
                    Text(
                      widget.articleModel.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn().slideX(delay: 200.ms),
                  const SizedBox(height: 12),
                  // Metadata row
                  Row(
                    children: [
                      if (widget.articleModel.author != null)
                        Expanded(
                          child: Text(
                            'By ${widget.articleModel.author}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (widget.articleModel.publishedAt != null)
                        Text(
                          DateFormat.yMMMd().format(widget.articleModel.publishedAt!),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.blue : null,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: _shareArticle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_browser),
                        onPressed: () => _launchInBrowser(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (widget.index * 100).ms).fadeIn().slideX();
  }

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) => NavigationDecision.navigate,
              ),
            )
            ..loadRequest(Uri.parse(widget.articleModel.url ?? 
              "https://news.google.com")),
        ),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    // TODO: Implement bookmark functionality with provider
  }

  void _shareArticle() {
    if (widget.articleModel.url != null) {
      Share.share(
        '${widget.articleModel.title}\n\nRead more at: ${widget.articleModel.url}',
        subject: widget.articleModel.title,
      );
    }
  }

  void _launchInBrowser(BuildContext context) async {
    if (widget.articleModel.url != null) {
      final Uri url = Uri.parse(widget.articleModel.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the article')),
          );
        }
      }
    }
  }
}
