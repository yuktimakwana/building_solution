import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget appBarWidget({
  required String title,
  Function()? leadingPress,
  required BuildContext context,
  required Color color,
  List<Widget>? action,
  TextEditingController? searchEditingController,
  Function()? onClose,
  Function()? backPress,
  bool showSearchBar = true,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(showSearchBar ? 100 : 60),
    child: StatefulBuilder(
      builder: (context, setState) {
        return AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: color,
          leading: (backPress != null)
              ? IconButton(
                  onPressed: backPress,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorConstant.naturalWhiteColor,
                  ),
                )
              : leadingPress != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: leadingPress,
                    icon: Image.asset(
                      '${ImageConstant.basePath}${ImageConstant.recycleBinImage}',
                    ),
                  ),
                )
              : const SizedBox(),
          title: Text(
            title,
            style: StyleConstant.bigTextStyle,
            textAlign: TextAlign.center,
          ),
          actions: action,
          bottom: showSearchBar
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: searchEditingController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(
                              Icons.search,
                              color: ColorConstant.lightGreyColor,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: onClose,
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: ColorConstant.darkGreyColor,
                            ),
                          ),
                          hintText: TextConstant.searchHere,
                          hintStyle: StyleConstant.mediumLightTextStyle,
                          contentPadding: const EdgeInsets.only(
                            bottom: 0,
                            left: 10,
                            top: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const PreferredSize(
                  preferredSize: Size.fromHeight(0),
                  child: SizedBox(),
                ),
        );
      },
    ),
  );
}
