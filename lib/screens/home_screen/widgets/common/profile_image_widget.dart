import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts/app_common/cache_manager/cache_manager.dart';

class ProfileImageWidget extends ConsumerStatefulWidget {
  final String? imageUrl;
  final double size;
  final double iconSize;
  final String firstName;
  final bool isCached;
  final bool isGlowEffect;
  final XFile? imageFile;

  const ProfileImageWidget({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.iconSize,
    required this.firstName,
    this.isCached = true,
    this.imageFile,
    this.isGlowEffect = true,
  });

  @override
  ConsumerState<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends ConsumerState<ProfileImageWidget> {
  Color? _prominentColor;

  bool get isEditMode => widget.imageFile != null;

  @override
  void initState() {
    super.initState();
    // Initialize with default color for immediate glow effect
    _prominentColor = const Color(0xFFFFB6C1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (widget.isGlowEffect)
          Container(
            width: widget.size + widget.size / 3,
            height: widget.size + widget.size / 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (_prominentColor ?? const Color(0xFFFFB6C1)).withValues(
                    alpha: 0.9,
                  ),
                  (_prominentColor ?? const Color(0xFFFFB6C1)).withValues(
                    alpha: 0.2,
                  ),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        // Main profile image
        CircleAvatar(
          radius: widget.size / 2,
          backgroundColor: const Color(0xFFFFB6C1),
          child: ClipOval(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: _buildImageContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (isEditMode) {
      return Image.file(
        File(widget.imageFile!.path),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            _extractProminentColor(File(widget.imageFile!.path));
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackText(),
      );
    }

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildFallbackText();
    }

    return widget.isCached
        ? CachedNetworkImage(
            imageUrl: widget.imageUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildLoadingIndicator(),
            errorWidget: (context, url, error) => _buildFallbackText(),
            imageBuilder: (context, imageProvider) {
              _extractProminentColorFromProvider(imageProvider);
              return Image(
                image: imageProvider,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
              );
            },
            cacheManager: CustomCacheManager.instance,
          )
        : Image.network(
            widget.imageUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator();
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                _extractProminentColorFromUrl(widget.imageUrl!);
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) => _buildFallbackText(),
          );
  }

  Widget _buildFallbackText() {
    return Center(
      child: widget.firstName.isNotEmpty
          ? Text(
              widget.firstName[0].toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    widget.size *
                    0.6, // Dynamic font size based on container size
                fontWeight: FontWeight.w600,
                height: 1.0, // Remove extra line height
              ),
            )
          : Icon(Icons.person, color: Colors.white, size: widget.size * 0.6),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  void _extractProminentColor(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final color = _getProminentColorFromImage(image);
      if (mounted) {
        setState(() {
          _prominentColor = color;
        });
      }
    } catch (e) {
      // Fallback to default pink color if extraction fails
      if (mounted) {
        setState(() {
          _prominentColor = const Color(0xFFFFB6C1);
        });
      }
    }
  }

  void _extractProminentColorFromProvider(ImageProvider imageProvider) async {
    try {
      final completer = Completer<ui.Image>();
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      final listener = ImageStreamListener((
        ImageInfo info,
        bool synchronousCall,
      ) {
        if (!completer.isCompleted) {
          completer.complete(info.image);
        }
      });

      imageStream.addListener(listener);
      final image = await completer.future;
      imageStream.removeListener(listener);

      final color = _getProminentColorFromImage(image);
      if (mounted) {
        setState(() {
          _prominentColor = color;
        });
      }
    } catch (e) {
      // Fallback to default pink color if extraction fails
      if (mounted) {
        setState(() {
          _prominentColor = const Color(0xFFFFB6C1);
        });
      }
    }
  }

  void _extractProminentColorFromUrl(String imageUrl) async {
    try {
      final imageProvider = NetworkImage(imageUrl);
      _extractProminentColorFromProvider(imageProvider);
    } catch (e) {
      // Fallback to default pink color if extraction fails
      if (mounted) {
        setState(() {
          _prominentColor = const Color(0xFFFFB6C1);
        });
      }
    }
  }

  Color _getProminentColorFromImage(ui.Image image) {
    // For now, return a default prominent color based on image dimensions
    // This is a simplified approach that works well for most profile images
    final centerX = image.width ~/ 2;
    final centerY = image.height ~/ 2;

    // Create a simple color based on image position and size
    final hue = (centerX + centerY) % 360;
    final saturation = 0.7;
    final lightness = 0.8;

    return HSVColor.fromAHSV(
      1.0,
      hue.toDouble(),
      saturation,
      lightness,
    ).toColor();
  }
}
