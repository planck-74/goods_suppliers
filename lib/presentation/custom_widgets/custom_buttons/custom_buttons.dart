import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget customButtonMoreScreen(
    {required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    GestureTapCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(
                width: 24,
              ),
              Text(
                text,
                style: TextStyle(color: color, fontSize: 12),
              )
            ],
          ),
          Divider(
            indent: 30,
            endIndent: 30,
            color: color,
          )
        ],
      ),
    ),
  );
}

Widget customButtonMoreScreenWithImage({
  required BuildContext context,
  required String text,
  required String icon,
  required Color color,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Row(
          children: [
            ImageIcon(
              AssetImage(icon),
              color: color,
            ),
            const SizedBox(
              width: 24,
            ),
            Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            )
          ],
        ),
        Divider(
          indent: 30,
          endIndent: 30,
          color: color,
        )
      ],
    ),
  );
}

Widget customCircularElevatedButton(
    {required IconData icon,
    required BuildContext context,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
    double? elevation}) {
  return SizedBox(
    height: 50,
    width: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(0), // Remove default padding
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor,
        size: 32,
      ),
    ),
  );
}

Widget customElevatedButtonRectangle(
    {required double screenWidth,
    required BuildContext context,
    required Widget child,
    double? screenHeight,
    Color? color,
    Color? colorBorderSide,
    VoidCallback? onPressed}) {
  return SizedBox(
    height: screenHeight ?? 50,
    width: screenWidth * 0.9,
    child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(color),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                      color: colorBorderSide ?? Colors.transparent))),
        ),
        child: child),
  );
}

Widget customOutlinedButton(
    {required double width,
    required double height,
    Color? backgroundColor,
    required BuildContext context,
    VoidCallback? onPressed,
    required Widget child}) {
  return SizedBox(
    width: width, // Set the width of the button
    height: height, // Set the height of the button
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: darkBlueColor, // Text color
        backgroundColor: backgroundColor ??
            Theme.of(context).hoverColor, // Button background color
        side: const BorderSide(
          color: darkBlueColor, // Border color
          width: 0.5, // Border width
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0), // Border radius
        ),
        padding:
            EdgeInsets.zero, // Remove internal padding to control size directly
      ),
      child: Center(child: child),
    ),
  );
}

class SmallRectangleButton extends StatefulWidget {
  const SmallRectangleButton(
      {super.key,
      required this.onPressed1,
      required this.onPressed2,
      required this.onPressed3,
      required this.currentIndex});
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;
  final VoidCallback onPressed3;

  final int currentIndex;
  @override
  State<SmallRectangleButton> createState() => _SmallRectangleButtonState();
}

class _SmallRectangleButtonState extends State<SmallRectangleButton> {
  @override
  @override
  Widget build(
    BuildContext context,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.8,
        ),
        SizedBox(
          height: 32,
          width: 85,
          child: ElevatedButton(
            onPressed: widget.currentIndex == 0
                ? widget.onPressed1
                : widget.onPressed2,
            style: ButtonStyle(
              shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: primaryColor),
                ),
              ),
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).hoverColor),
            ),
            child: Text(
              widget.currentIndex == 1 ? 'دخول' : 'التالي',
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        widget.currentIndex > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 32,
                    width: 85,
                    child: ElevatedButton(
                      onPressed: widget.onPressed3,
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: primaryColor),
                          ),
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).hoverColor),
                      ),
                      child: const Text(
                        'السابق',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}

Widget customcubidalElevatedButton(
    {IconData? icon,
    required BuildContext context,
    required Color backgroundColor,
    Color? iconColor,
    required VoidCallback onPressed,
    Widget? child,
    double? iconSize,
    double? elevation,
    double? height,
    double? width}) {
  return SizedBox(
    height: height ?? 50,
    width: width ?? 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),

        padding: const EdgeInsets.all(0), // Remove default padding
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: child ??
          Icon(
            icon,
            color: iconColor,
            size: iconSize ?? 32,
          ),
    ),
  );
}
