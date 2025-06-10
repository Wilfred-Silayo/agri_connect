import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StockImageCarousel extends StatefulWidget {
  final List<String> images;
  final String stockId; // for mapping indicators
  final double height;

  const StockImageCarousel({
    super.key,
    required this.images,
    required this.stockId,
    this.height = 250,
  });

  @override
  State<StockImageCarousel> createState() => _StockImageCarouselState();
}

class _StockImageCarouselState extends State<StockImageCarousel> {
  late int _currentImageIndex;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items:
              widget.images.map((imageUrl) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              widget.images.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == entry.key
                            ? Colors.green
                            : Colors.grey[400],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
