import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_duel_disk/packages/features/feature_draw_card/lib/src/draw_card_viewmodel.dart';
import 'package:smart_duel_disk/packages/ui_components/lib/ui_components.dart';
import 'package:smart_duel_disk/packages/wrappers/wrapper_assets/wrapper_assets_interface/lib/wrapper_assets_interface.dart';

class DrawCardScreen extends StatefulWidget {
  const DrawCardScreen();

  @override
  _DrawCardScreenState createState() => _DrawCardScreenState();
}

class _DrawCardScreenState extends State<DrawCardScreen> {
  static const _animationDuration = Duration(milliseconds: 500);

  Widget _cardImage;

  bool _isAnimating = true;
  bool _isAnimationStarted = false;

  @override
  void initState() {
    super.initState();

    // Make the app full screen.
    SystemChrome.setEnabledSystemUIOverlays([]);

    final assetsProvider = Provider.of<AssetsProvider>(context, listen: false);
    _cardImage = _CardImage(imageAssetId: assetsProvider.cardBack);

    _startAnimation();
  }

  @override
  void dispose() {
    // Show the status bar and bottom bar again.
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ]);

    super.dispose();
  }

  void _startAnimation() {
    Future.delayed(const Duration(), () {
      setState(() => _isAnimationStarted = true);
      Future.delayed(_animationDuration, () {
        setState(() => _isAnimating = false);
      });
    });
  }

  Future<void> _onCardDrawn() {
    setState(() => _cardImage = const SizedBox.shrink());

    final vm = Provider.of<DrawCardViewModel>(context, listen: false);
    return vm.onCardDrawn();
  }

  @override
  Widget build(BuildContext context) {
    final assetsProvider = Provider.of<AssetsProvider>(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final animatingBottomOffset = screenHeight * 2;
    final animatingTopOffset = animatingBottomOffset * -1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(),
          Positioned.fill(
            child: _CardDragTarget(onCardDrawn: _onCardDrawn),
          ),
          if (_isAnimating) ...{
            AnimatedPositioned(
              duration: _animationDuration,
              curve: Curves.fastOutSlowIn,
              top: _isAnimationStarted ? 0 : animatingTopOffset,
              bottom: _isAnimationStarted ? 0 : animatingBottomOffset,
              child: _CardImage(imageAssetId: assetsProvider.cardBack),
            ),
          } else ...{
            _CardDraggable(cardImage: _cardImage),
          }
        ],
      ),
    );
  }
}

class _CardDragTarget extends StatelessWidget {
  final VoidCallback onCardDrawn;

  const _CardDragTarget({
    @required this.onCardDrawn,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (_, __, ___) => const SizedBox.expand(),
      onLeave: (_) => onCardDrawn(),
    );
  }
}

class _CardDraggable extends StatelessWidget {
  final Widget cardImage;

  const _CardDraggable({
    @required this.cardImage,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Object>(
      axis: Axis.vertical,
      maxSimultaneousDrags: 1,
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: HapticFeedback.heavyImpact,
      feedback: cardImage,
      child: cardImage,
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageAssetId;

  const _CardImage({
    @required this.imageAssetId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Image.asset(
      imageAssetId,
      width: screenWidth,
      fit: BoxFit.fitWidth,
    );
  }
}
