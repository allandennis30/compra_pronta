import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final Function(ImageSource) onPickImage;
  final VoidCallback onReset;

  const ImagePickerWidget({
    Key? key,
    this.selectedImage,
    this.imageUrl,
    required this.onPickImage,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage =
        selectedImage != null || (imageUrl != null && imageUrl!.isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;

        return Container(
          width: double.infinity,
          height: isDesktop ? 300 : (isTablet ? 250 : 200),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: hasImage ? _buildSelectedImage() : _buildPlaceholder(),
        );
      },
    );
  }

  Widget _buildSelectedImage() {
    Widget imageWidget;

    if (selectedImage != null) {
      imageWidget = Image.file(
        selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text('Erro ao carregar imagem'),
              ],
            ),
          );
        },
      );
    } else {
      imageWidget = const SizedBox();
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black.withOpacity(0.7),
            child: IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              onPressed: onReset,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black.withOpacity(0.7),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _showImageSourceActionSheet(
                onCamera: () => onPickImage(ImageSource.camera),
                onGallery: () => onPickImage(ImageSource.gallery),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return InkWell(
      onTap: () => _showImageSourceActionSheet(
        onCamera: () => onPickImage(ImageSource.camera),
        onGallery: () => onPickImage(ImageSource.gallery),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.add_photo_alternate,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Adicionar foto do produto',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toque para selecionar',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet(
      context: _getContext(),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  onCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  onGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  BuildContext _getContext() {
    final context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    if (context != null) return context;

    // Fallback
    throw FlutterError('Não foi possível obter o contexto do widget');
  }
}
