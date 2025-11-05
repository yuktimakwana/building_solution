import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/widgets/default_image.dart';
import 'package:duplicate_building_solution/widgets/material_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectListWidget extends StatelessWidget {
  final String image;
  final String title1;
  final String title2;
  final bool isRecycleBinScreen;
  final Function() onTap, onPressed;
  final Function()? onDelete;

  const ProjectListWidget(
      {super.key,
      required this.image,
      required this.onTap,
      required this.title1,
      required this.onPressed,
      this.onDelete,
      required this.title2,
      required this.isRecycleBinScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
      child: MaterialWidget(
        child: ListTile(
            onTap: onTap,
            horizontalTitleGap: 4,
            leading: DefaultImage(
              title: image,
              height: 35.w,
            ),
            title: Text(title1, style: StyleConstant.mediumTextStyle),
            subtitle: Text(title2, style: StyleConstant.smallLightTextStyle),
            trailing: isRecycleBinScreen
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete,
                            color: ColorConstant.pastelRedColor,
                          )),
                      IconButton(
                          onPressed: onPressed,
                          icon: const Icon(
                            Icons.undo,
                            color: ColorConstant.pastelRedColor,
                          )),
                    ],
                  )
                : IconButton(
                    icon: Image.asset(
                        '${ImageConstant.basePath}${ImageConstant.deleteImage}',
                        height: 20),
                    onPressed: onPressed)),
      ),
    );
  }
}
