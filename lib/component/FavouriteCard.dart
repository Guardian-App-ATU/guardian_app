import 'package:flutter/material.dart';

class FavouriteCard extends StatelessWidget {
  const FavouriteCard({
    Key? key,
    required this.favouriteData,
  }) : super(key: key);

  final favouriteData;

  @override
  Widget build(BuildContext context) {
    var avatar = favouriteData["avatar"];

    return PopupMenuButton<int>(
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(child: Text("Remove"), value: 0,)
      ],
      onSelected: (value) {
        if(value == 0){

        }
      },
      elevation: 8,
      child: Card(
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
                  child: avatar != null ? Image.network(avatar) : const Icon(Icons.person)),
              Positioned(
                  left: 3,
                  bottom: 3,
                  child: Text(
                    favouriteData["displayName"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8
                    ),
                    textScaleFactor: 1,
                  ))
            ],
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}