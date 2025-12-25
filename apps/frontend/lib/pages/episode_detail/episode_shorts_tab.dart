import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/extensions/media_query_extensions.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/page_top_bar.dart';

class EpisodeShortsTab extends StatefulWidget {
  const EpisodeShortsTab({super.key});

  @override
  State<EpisodeShortsTab> createState() => _EpisodeShortsTabState();
}

class _EpisodeShortsTabState extends State<EpisodeShortsTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  XFile? _selectedImage;
  String _selectedService = 'luma_dream_machine';
  bool _isGenerating = false;
  Uint8List? _generatedVideo;
  String? _error;

  final List<Map<String, String>> _serviceTypes = [
    {'value': 'luma_dream_machine', 'label': 'Luma Dream Machine'},
    {'value': 'stable_video_diffusion', 'label': 'Stable Video Diffusion'},
    {'value': 'animatediff', 'label': 'AnimateDiff'},
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('Image picker tapped'); // Debug
    try {
      print('Opening image picker...'); // Debug
      
      // Try image picker - it should work on web too
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      print('Image picker result: ${image?.path}'); // Debug
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _error = null;
        });
        print('Image selected: ${image.path}'); // Debug
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('No image selected - user cancelled'); // Debug
      }
    } catch (e, stackTrace) {
      print('Image picker error: $e'); // Debug
      print('Stack trace: $stackTrace'); // Debug
      setState(() {
        _error = 'Failed to pick image: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _generateVideo() async {
    if (_selectedImage == null) {
      setState(() {
        _error = 'Please select an image first';
      });
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedVideo = null;
    });

    try {
      // For web, we need to read the file as bytes first
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await _selectedImage!.readAsBytes();
      } else {
        imageBytes = await File(_selectedImage!.path).readAsBytes();
      }
      
      final videoBytes = await _apiService.generateVideo(
        imageBytes: imageBytes,
        prompt: _promptController.text.trim(),
        serviceType: _selectedService,
      );

      setState(() {
        _generatedVideo = videoBytes;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Failed to generate video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTopBar(title: 'Shorts'),
        Expanded(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.isMobile ? 16 : 24),
                // Image Selector
                _buildImageSelector(),
                SizedBox(height: context.isMobile ? 16 : 24),
                // Service Type Dropdown
                _buildServiceDropdown(),
                SizedBox(height: context.isMobile ? 16 : 24),
                // Prompt Input
                _buildPromptInput(),
                SizedBox(height: context.isMobile ? 16 : 24),
                // Generate Button
                _buildGenerateButton(),
                SizedBox(height: context.isMobile ? 16 : 24),
                // Error Display
                if (_error != null) _buildErrorDisplay(),
                SizedBox(height: context.isMobile ? 16 : 24),
                // Generated Video Display
                if (_generatedVideo != null) _buildVideoDisplay(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Image',
          style: TextStyle(
            fontSize: context.isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: context.isMobile ? 200 : 300,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppColors.primary
                      : AppColors.textMuted.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: context.isMobile ? 48 : 64,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: context.isMobile ? 8 : 12),
                      Text(
                        'Tap to select image',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.isMobile ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Generation Service',
          style: TextStyle(
            fontSize: context.isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedService,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.isMobile ? 14 : 16,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textMuted,
              ),
              items: _serviceTypes.map((service) {
                return DropdownMenuItem<String>(
                  value: service['value'],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isMobile ? 12 : 16,
                    ),
                    child: Text(service['label']!),
                  ),
                );
              }).toList(),
              onChanged: _isGenerating
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedService = newValue;
                        });
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prompt',
          style: TextStyle(
            fontSize: context.isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _promptController,
            enabled: !_isGenerating,
            maxLines: 4,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.isMobile ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: 'Describe the video animation you want to generate...',
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.isMobile ? 14 : 16,
              ),
              contentPadding: EdgeInsets.all(context.isMobile ? 16 : 20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isGenerating || _selectedImage == null)
            ? null
            : _generateVideo,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 16 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: context.isMobile ? 12 : 16),
                  Text(
                    'Generating...',
                    style: TextStyle(
                      fontSize: context.isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: context.isMobile ? 20 : 24,
                  ),
                  SizedBox(width: context.isMobile ? 8 : 12),
                  Text(
                    'Generate Video',
                    style: TextStyle(
                      fontSize: context.isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: context.isMobile ? 20 : 24,
          ),
          SizedBox(width: context.isMobile ? 12 : 16),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: context.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated Video',
          style: TextStyle(
            fontSize: context.isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: context.isMobile ? 12 : 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _generatedVideo != null
                ? _buildVideoPlayer()
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    // For web, we can use a video element
    // For desktop/mobile, we might need a video player package
    // For now, show a placeholder with download option
    return Container(
      height: context.isMobile ? 300 : 400,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Video Generated Successfully',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_generatedVideo!.length / 1024 / 1024).toStringAsFixed(2)} MB',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.isMobile ? 12 : 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement video download/playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video download/playback will be implemented soon'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
