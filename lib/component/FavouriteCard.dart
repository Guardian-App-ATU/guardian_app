import 'package:flutter/material.dart';

class FavouriteCard extends StatelessWidget {
  const FavouriteCard({
    Key? key,
    required this.favouriteData,
  }) : super(key: key);

  final favouriteData;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        child: Stack(
          children: [
            Container(
                foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.5),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0, 0.55])),
                child: Image.network(favouriteData!["avatar"])),
            Positioned(
                left: 3,
                bottom: 3,
                child: Text(
                  favouriteData!["displayName"],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8
                  ),
                ))
          ],
        ),
        fit: BoxFit.fill,
      ),
    );
  }
}