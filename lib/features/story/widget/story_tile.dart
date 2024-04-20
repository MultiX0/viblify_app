import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../../auth/models/user_model.dart';
import '../models/story_model.dart';

class StoryTile extends StatelessWidget {
  final Story story;
  final UserModel story_author;
  final UserModel myData;
  const StoryTile({
    super.key,
    required this.story,
    required this.story_author,
    required this.myData,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = myData.userID == story_author.userID;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 150,
          width: 90,
          child: Stack(
            children: [
              if (story.views.contains(myData.userID)) ...[
                Positioned.fill(
                  child: Image(
                    image: CachedNetworkImageProvider(
                      story.content_url.isEmpty ? story_author.profilePic : story.content_url,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ] else ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: const GradientBoxBorder(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image(
                        image: CachedNetworkImageProvider(
                          story.content_url.isEmpty ? story_author.profilePic : story.content_url,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.65)],
                  ),
                ),
              ),
              if (!isMe) ...[
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade800, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[900],
                            backgroundImage: CachedNetworkImageProvider(story_author.profilePic),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            "@${story_author.userName}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[200],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    !isMe ? story_author.name : "You",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
