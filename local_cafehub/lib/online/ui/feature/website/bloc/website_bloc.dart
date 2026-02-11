import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/models/website/website_model.dart';
import 'package:bhansa_ghar/online/core/repositories/website_repository.dart';
import 'package:flutter/material.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'dart:io';

// Events
abstract class WebsiteEvent extends Equatable {
  const WebsiteEvent();

  @override
  List<Object?> get props => [];
}

class FetchWebsiteDataEvent extends WebsiteEvent {
  const FetchWebsiteDataEvent();
}

class UpdateWebsiteDataEvent extends WebsiteEvent {
  final WebsiteData websiteData;
  const UpdateWebsiteDataEvent(this.websiteData);

  @override
  List<Object?> get props => [websiteData];
}

class FetchPublicWebsiteDataEvent extends WebsiteEvent {
  final String restaurantSlug;
  const FetchPublicWebsiteDataEvent(this.restaurantSlug);

  @override
  List<Object?> get props => [restaurantSlug];
}

class UploadWebsiteImageEvent extends WebsiteEvent {
  final File imageFile;
  final String imageType; // 'logo', 'favicon', 'about_image', 'hero_image'
  const UploadWebsiteImageEvent({
    required this.imageFile,
    required this.imageType,
  });

  @override
  List<Object?> get props => [imageFile, imageType];
}

class UpdateWebsiteSectionEvent extends WebsiteEvent {
  final WebsiteData websiteData;
  final String sectionName;
  const UpdateWebsiteSectionEvent({
    required this.websiteData,
    required this.sectionName,
  });

  @override
  List<Object?> get props => [websiteData, sectionName];
}

class ResetWebsiteToDefaultEvent extends WebsiteEvent {
  const ResetWebsiteToDefaultEvent();
}

// States
abstract class WebsiteState extends Equatable {
  const WebsiteState();

  @override
  List<Object?> get props => [];
}

class WebsiteInitialState extends WebsiteState {
  const WebsiteInitialState();
}

class WebsiteLoadingState extends WebsiteState {
  const WebsiteLoadingState();
}

class WebsiteLoadedState extends WebsiteState {
  final WebsiteData websiteData;
  const WebsiteLoadedState(this.websiteData);

  @override
  List<Object?> get props => [websiteData];
}

class WebsiteErrorState extends WebsiteState {
  final String message;
  const WebsiteErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class WebsiteUpdatingState extends WebsiteState {
  final WebsiteData websiteData;
  const WebsiteUpdatingState(this.websiteData);

  @override
  List<Object?> get props => [websiteData];
}

class WebsiteUpdatedState extends WebsiteState {
  final WebsiteData websiteData;
  const WebsiteUpdatedState(this.websiteData);

  @override
  List<Object?> get props => [websiteData];
}

class WebsiteImageUploadingState extends WebsiteState {
  final WebsiteData websiteData;
  final String imageType;
  final double progress;
  const WebsiteImageUploadingState({
    required this.websiteData,
    required this.imageType,
    required this.progress,
  });

  @override
  List<Object?> get props => [websiteData, imageType, progress];
}

class WebsiteImageUploadedState extends WebsiteState {
  final WebsiteData websiteData;
  final String imageType;
  final String imageUrl;
  const WebsiteImageUploadedState({
    required this.websiteData,
    required this.imageType,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [websiteData, imageType, imageUrl];
}

class WebsiteSectionUpdatedState extends WebsiteState {
  final WebsiteData websiteData;
  final String sectionName;
  const WebsiteSectionUpdatedState({
    required this.websiteData,
    required this.sectionName,
  });

  @override
  List<Object?> get props => [websiteData, sectionName];
}

// BLoC
class WebsiteBloc extends Bloc<WebsiteEvent, WebsiteState> {
  final WebsiteRepository _websiteRepository;

  WebsiteBloc(this._websiteRepository) : super(const WebsiteInitialState()) {
    on<FetchWebsiteDataEvent>(_onFetchWebsiteData);
    on<UpdateWebsiteDataEvent>(_onUpdateWebsiteData);
    on<FetchPublicWebsiteDataEvent>(_onFetchPublicWebsiteData);
    on<UploadWebsiteImageEvent>(_onUploadWebsiteImage);
    on<UpdateWebsiteSectionEvent>(_onUpdateWebsiteSection);
    on<ResetWebsiteToDefaultEvent>(_onResetWebsiteToDefault);
  }

  Future<void> _onFetchWebsiteData(
    FetchWebsiteDataEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint('WebsiteBloc: FetchWebsiteDataEvent started');
      emit(const WebsiteLoadingState());

      final websiteData = await _websiteRepository.getWebsiteData();

      debugPrint('WebsiteBloc: Website data fetched successfully');
      emit(WebsiteLoadedState(websiteData));
    } catch (e) {
      debugPrint('WebsiteBloc: Error fetching website data: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }

  Future<void> _onUpdateWebsiteData(
    UpdateWebsiteDataEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint('WebsiteBloc: UpdateWebsiteDataEvent started');
      emit(WebsiteUpdatingState(event.websiteData));

      final updatedData = await _websiteRepository.updateWebsiteData(
        event.websiteData,
      );

      debugPrint('WebsiteBloc: Website data updated successfully');
      emit(WebsiteUpdatedState(updatedData));
      emit(WebsiteLoadedState(updatedData));
    } catch (e) {
      debugPrint('WebsiteBloc: Error updating website data: $e');
      // Keep the last loaded state if we have one
      if (state is WebsiteLoadedState) {
        emit(state);
      }
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }

  Future<void> _onFetchPublicWebsiteData(
    FetchPublicWebsiteDataEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint('WebsiteBloc: FetchPublicWebsiteDataEvent started');
      emit(const WebsiteLoadingState());

      final websiteData = await _websiteRepository.getPublicWebsiteData(
        event.restaurantSlug,
      );

      debugPrint('WebsiteBloc: Public website data fetched successfully');
      emit(WebsiteLoadedState(websiteData));
    } catch (e) {
      debugPrint('WebsiteBloc: Error fetching public website data: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }

  Future<void> _onUploadWebsiteImage(
    UploadWebsiteImageEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint(
        'WebsiteBloc: UploadWebsiteImageEvent started for ${event.imageType}',
      );

      // Get current state if available
      final currentState = state;
      final currentData = currentState is WebsiteLoadedState
          ? currentState.websiteData
          : currentState is WebsiteUpdatingState
          ? currentState.websiteData
          : null;

      if (currentData == null) {
        emit(WebsiteErrorState('No website data loaded'));
        return;
      }

      // Emit uploading state with progress
      emit(
        WebsiteImageUploadingState(
          websiteData: currentData,
          imageType: event.imageType,
          progress: 0.0,
        ),
      );

      // Upload image
      final imageUrl = await _websiteRepository.uploadWebsiteImage(
        event.imageFile,
        event.imageType,
      );

      debugPrint('WebsiteBloc: Image uploaded successfully: $imageUrl');

      // Update website data with new image URL
      WebsiteData updatedData;
      switch (event.imageType) {
        case 'logo':
          updatedData = currentData.copyWith(logo: imageUrl);
          break;
        case 'favicon':
          updatedData = currentData.copyWith(favicon: imageUrl);
          break;
        case 'about_image':
          updatedData = currentData.copyWith(aboutImage: imageUrl);
          break;
        case 'hero_image':
          // Hero image would be stored separately if needed
          updatedData = currentData;
          break;
        default:
          updatedData = currentData;
      }

      emit(
        WebsiteImageUploadedState(
          websiteData: updatedData,
          imageType: event.imageType,
          imageUrl: imageUrl,
        ),
      );

      // Emit loaded state with updated data
      emit(WebsiteLoadedState(updatedData));
    } catch (e) {
      debugPrint('WebsiteBloc: Error uploading website image: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }

  Future<void> _onUpdateWebsiteSection(
    UpdateWebsiteSectionEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint(
        'WebsiteBloc: UpdateWebsiteSectionEvent started for ${event.sectionName}',
      );

      emit(WebsiteUpdatingState(event.websiteData));

      final updatedData = await _websiteRepository.updateWebsiteData(
        event.websiteData,
      );

      debugPrint(
        'WebsiteBloc: Section ${event.sectionName} updated successfully',
      );

      emit(
        WebsiteSectionUpdatedState(
          websiteData: updatedData,
          sectionName: event.sectionName,
        ),
      );

      emit(WebsiteLoadedState(updatedData));
    } catch (e) {
      debugPrint(
        'WebsiteBloc: Error updating section ${event.sectionName}: $e',
      );
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }

  Future<void> _onResetWebsiteToDefault(
    ResetWebsiteToDefaultEvent event,
    Emitter<WebsiteState> emit,
  ) async {
    try {
      debugPrint('WebsiteBloc: ResetWebsiteToDefaultEvent started');

      final websiteData = await _websiteRepository.getWebsiteData();

      debugPrint('WebsiteBloc: Website data reset to default');
      emit(WebsiteLoadedState(websiteData));
    } catch (e) {
      debugPrint('WebsiteBloc: Error resetting website data: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(WebsiteErrorState(errorMessage));
    }
  }
}
