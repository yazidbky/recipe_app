// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:recipe_app/components/custom_paint.dart';

class UploadCard extends StatelessWidget {
  final String drgaFile;
  final void Function()? onTap;
  final Widget? child;

  const UploadCard({
    super.key,
    required this.drgaFile,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: screenHeight * 0.3, // Increased height
        width: screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: CustomPaint(
                    painter: DashedBorderPainter(),
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: child ??
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ),
                                  Text(drgaFile),
                                ],
                              ),
                        ),
                      ),
                    ),
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
