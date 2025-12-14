import 'package:equatable/equatable.dart';

class GalleryItem extends Equatable {
  final String id;
  final String image;
  final String? video;

  const GalleryItem({
    required this.id,
    required this.image,
    this.video,
  });

  @override
  List<Object?> get props => [id, image, video];
}
