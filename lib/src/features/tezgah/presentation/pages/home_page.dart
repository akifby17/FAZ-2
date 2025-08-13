import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/get_tezgahlar.dart';
import '../../domain/entities/tezgah.dart';
import '../../domain/repositories/tezgah_repository.dart';
import '../bloc/tezgah_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GetTezgahlar usecase = GetTezgahlar(GetIt.I<TezgahRepository>());
    return BlocProvider(
      create: (_) => TezgahBloc(getTezgahlar: usecase)..add(TezgahFetched()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title_looms'.tr()),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) {
              context.setLocale(locale);
              // Save to Hive
              GetIt.I<Box<dynamic>>().put('locale_code', locale.languageCode);
            },
            itemBuilder: (context) => [
              PopupMenuItem<Locale>(
                value: const Locale('tr'),
                child: Text('language_turkish'.tr()),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Text('language_english'.tr()),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupDropdown(),
            const SizedBox(height: 12),
            _SelectAllRow(),
            const SizedBox(height: 12),
            const Expanded(child: _TezgahGrid()),
            const SizedBox(height: 12),
            _BottomActions(),
          ],
        ),
      ),
    );
  }
}

class _GroupDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TezgahBloc, TezgahState>(
      builder: (context, state) {
        final List<String> groups = state.groups;
        return DropdownButtonFormField<String?>(
          value: state.selectedGroup,
          items: [
            DropdownMenuItem<String?>(value: null, child: Text('all'.tr())),
            ...groups
                .map((g) => DropdownMenuItem<String?>(value: g, child: Text(g)))
          ],
          onChanged: (value) =>
              context.read<TezgahBloc>().add(TezgahGroupChanged(value)),
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'label_group'.tr()),
        );
      },
    );
  }
}

class _SelectAllRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: context.select<TezgahBloc, bool>((b) {
            final s = b.state;
            return s.items.isNotEmpty && s.items.every((e) => e.isSelected);
          }),
          onChanged: (v) =>
              context.read<TezgahBloc>().add(TezgahSelectAll(v ?? false)),
        ),
        Text('select_all'.tr()),
      ],
    );
  }
}

class _TezgahGrid extends StatelessWidget {
  const _TezgahGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TezgahBloc, TezgahState>(
      builder: (context, state) {
        if (state.status == TezgahStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == TezgahStatus.failure) {
          return Center(child: Text('error_load_failed'.tr()));
        }
        final List<Tezgah> items = state.items;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            const double spacing = 12;
            // Dinamik kolon sayısı: her cihaz/orientasyon için uygun
            final media = MediaQuery.of(context);
            final bool isTablet = media.size.shortestSide >= 600;
            final bool isLandscape = media.orientation == Orientation.landscape;
            final double desiredTileWidth = isTablet
                ? (isLandscape ? 220 : 200)
                : (isLandscape ? 180 : 160);
            int crossAxisCount = (maxWidth / desiredTileWidth).floor();
            crossAxisCount = crossAxisCount.clamp(2, 10);

            // Hesaplanan hücre genişliğine göre aspect ratio
            final double totalSpacing = spacing * (crossAxisCount - 1);
            final double tileWidth = (maxWidth - totalSpacing) / crossAxisCount;
            final double tileHeight =
                isLandscape ? 100 : 140; // başlık + 2 satır
            final double childAspectRatio = tileWidth / tileHeight;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final Tezgah item = items[index];
                return GestureDetector(
                  onTap: () => context
                      .read<TezgahBloc>()
                      .add(TezgahToggleSelection(item.id)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _eventBackgroundColor(item.eventId),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: item.isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _TileText(
                          text: item.loomNo,
                          style: Theme.of(context).textTheme.titleMedium!,
                          eventId: item.eventId,
                        ),
                        const SizedBox(height: 4),
                        _TileText(
                          text: item.weaverName,
                          style: Theme.of(context).textTheme.bodySmall!,
                          eventId: item.eventId,
                          maxLines: 1,
                        ),
                        if (item.operationName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          _TileText(
                            text: item.operationName,
                            style: Theme.of(context).textTheme.bodySmall!,
                            eventId: item.eventId,
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Color _eventBackgroundColor(int eventId) {
  switch (eventId) {
    case 1:
      return Colors.grey.shade200;
    case 2:
      return Colors.red.shade400;
    case 3:
      return const Color(0xFF24456E);
    default:
      return Colors.grey.shade100;
  }
}

class _TileText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int eventId;
  final int maxLines;

  const _TileText({
    required this.text,
    required this.style,
    required this.eventId,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLightText = eventId == 2 || eventId == 3;
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style.copyWith(
        color: useLightText ? Colors.white : Colors.black87,
        fontWeight: style.fontSize != null && style.fontSize! >= 18
            ? FontWeight.w600
            : null,
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tablet/telefon ayrımı için responsive düzen
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 600;
    final bool hasSelection = context.select<TezgahBloc, bool>(
        (b) => b.state.items.any((e) => e.isSelected));

    String _selectedLoomsText() {
      final items = context.read<TezgahBloc>().state.items;
      return items.where((e) => e.isSelected).map((e) => e.loomNo).join(',');
    }

    final List<Widget> buttons = [
      ElevatedButton(
        onPressed: hasSelection
            ? () {
                context.pushNamed('weaving', extra: _selectedLoomsText());
              }
            : null,
        child: Text('btn_weaver'.tr()),
      ),
      ElevatedButton(
        onPressed: hasSelection
            ? () {
                context.pushNamed('operations', extra: _selectedLoomsText());
              }
            : null,
        child: Text('btn_op_start'.tr()),
      ),
      ElevatedButton(
        onPressed:
            hasSelection ? () => context.push('/operations?end=true') : null,
        child: Text('btn_op_end'.tr()),
      ),
      ElevatedButton(
        onPressed: hasSelection ? () => context.pushNamed('fabric') : null,
        child: Text('btn_fabric'.tr()),
      ),
      ElevatedButton(
        onPressed: hasSelection ? () => context.pushNamed('warp') : null,
        child: Text('btn_warp'.tr()),
      ),
    ];

    if (isWide) {
      // Tablet ve yatay modda tek satırda hepsi
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons
            .map((b) => SizedBox(height: 44, child: b))
            .toList(growable: false),
      );
    }

    // Dar ekranlarda iki satırlı düzen
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: buttons
          .map((b) =>
              SizedBox(width: (width - 16 * 2 - 12) / 2, height: 44, child: b))
          .toList(growable: false),
    );
  }
}
