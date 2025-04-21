import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  final List<String> filters = ['Shop', 'Style', 'Sports', 'Auto', 'Music'];

  final List<Map<String, dynamic>> items = [
    {
      "image": "assets/Rectangle.png",
      "title": "Interviews with leading designers of large companies",
      "user": "amanda_design",
      "views": "37.2k views",
      "time": "9:14"
    },
    {
      "image": "assets/Rectangle1.png",
      "title": "Regular and studio shooting comparison",
      "user": "photo.master",
      "views": "52.4k views",
      "time": "5:23"
    },
    {
      "image": "assets/Rectangle2.png",
      "title": "Ocean life – Indian Ocean",
      "user": "marine.bio",
      "views": "16.8k views",
      "time": "9:14"
    },
    {
      "image": "assets/Rectangle3.png",
      "title": "Cute badges",
      "user": "photo.master",
      "views": "17.2k views",
      "time": "3:26"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(
                    "assets/backicon.png",
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Explore",
                        style: TextStyle(
                          color: Color(0xff141414),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 19,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xffF7F7F7),
                  border:
                      Border.all(color: const Color(0xffCCCDCF), width: 0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 0, top: 2),
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Color(0xff808187),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Container(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: Image.asset(
                          "assets/searchicon.png",
                          height: 20,
                          width: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 13),

            /// Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Chip(
                        label: index == 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/shopicon.png",
                                    height: 14.5,
                                    width: 12.5,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    filters[index],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff262626)),
                                  ),
                                ],
                              )
                            : Text(
                                filters[index],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff262626)),
                              ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                              color: Color(0xff3C3C43).withValues(alpha: 0.18)),
                        ));
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  childAspectRatio: 9 / 14,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Stack(
                    children: [
                      Image.asset(
                        item['image'],
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Text(
                            item['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffFEFEFE),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${item['user']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffFEFEFE),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${item['views']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffFEFEFE),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
