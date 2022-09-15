import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kin_music_player_app/components/kin_progress_indicator.dart';
import 'package:kin_music_player_app/services/network/api_service.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> urls = [
      // 'https://feres.et/Content/images/slide_1.jpg',
      // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUyBTw5J4u3OpkQpq9DE6g2rUPcv0Vde9Nkg&usqp=CAU',
      // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdBrJnhzlS504lqvTbJHd-PPxFHUJilbkD5A&usqp=CAU',
      // ""
      "assets/images/kuraz kin banner_am.jpg",
      "assets/images/kuraz kin banner_en.jpg"
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder(
          future: getCompanyProfile('/company/profile'),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (!(snapshot.connectionState == ConnectionState.waiting)) {
              return CarouselSlider.builder(
                itemCount: urls.length,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  autoPlay: true,
                  height: 200,

                  // aspectRatio: 5,
                ),
                itemBuilder: (context, index, realIndex) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(urls[index]),
                            fit: BoxFit.fill,
                          ),
                        ),
                      )

                      //  CachedNetworkImage(
                      //   imageUrl: urls[index],
                      //   imageBuilder: (context, imageProvider) => Container(
                      //     // height: 200,
                      //     //  width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(20),
                      //       image: DecorationImage(
                      //         image: imageProvider,
                      //         fit: BoxFit.fill,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      );
                },
              );
            }
            return const Center(
              child: KinProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
