import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/profile/presentation/widgets/veripoints/veripoints_controller.dart';

class VeriPointsWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VeriPointsWidgetState();
}

class _VeriPointsWidgetState extends ConsumerState<VeriPointsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(veriPointsControllerProvider.notifier).getVeriPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final veriPoints = ref.watch(veriPointsControllerProvider);
    return veriPoints.when<Widget>(
      data: (points) {
        return Column(
          children: [
            Text(
              'VeriPoints',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              points.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        );
      },
      loading: () {
        return const VShimmerWidget(
          height: 50,
          width: 150,
        );
      },
      error: (error, stackTrace) {
        return Column(
          children: [
            Text(
              'VeriPoints',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        );
      },
    );
  }
}
