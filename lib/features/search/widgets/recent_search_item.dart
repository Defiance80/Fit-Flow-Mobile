import 'package:fitflow/common/widgets/custom_image.dart';
import 'package:fitflow/core/constants/app_icons.dart';
import 'package:fitflow/features/search/cubits/recent_searches_cubit.dart';
import 'package:fitflow/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/common/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentSearchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const RecentSearchItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.color.outline),
          ),
        ),
        child: Padding(
          padding: const .symmetric(vertical: 10),
          child: Row(
            children: [
              // Circle avatar with icon placeholder
              const CustomImage.circular(
                  width: 43,
                  height: 43,
                  imageUrl:
                      'https://s3-alpha-sig.figma.com/img/37e2/e608/2a8a053d7129ed581afcda2065b8726e?Expires=1745193600&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=m25Y~n8qVreqDZWEuhO~r-nH6~79I4KLTKPn-6JoaJandq~8t7cdlKWXTUmV9paOB6wRdfqX-CTkoF5RsIuldsupoVPFnASnQKr2Dip7y1XRpTDtypMt05Dxz91YlIn1vDS-aLPshzfz~Ojt11q8MnqCjVuu6lPiTYuYjoU3BFS6oJ-ov5chivcLqRTBLt6b3aQKnEcIc55mHjjJIep1etE8f8VBXofAz8CnGRuMyUBhM0PyXAE4pWelZmvoE9juzp36QyVJ9yK1c7dQYbiL1vvmn4sV3UeBegcCw6GHj0PMPsItz82hiZKbnDf5kgpf0RX7fkRREFv64P4~3qR20A__'),
              const SizedBox(width: 15),

              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    CustomText(
                      title,
                      fontSize: 16,
                      style: Theme.of(context).textTheme.bodyLarge!,
                    ),
                    const SizedBox(height: 5),
                    CustomText(
                      subtitle,
                      fontSize: 12,
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                  ],
                ),
              ),

              GestureDetector(
                  onTap: () {
                    _onTapRemove(context, title);
                  },
                  child: CustomImage(
                    AppIcons.closeCircle,
                    color: context.color.onSurface,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapRemove(BuildContext context, String text) {
    context.read<RecentSearchesCubit>().removeRecentSearch(text);
  }
}
