//
//  CPVideoPredefined.h
//  11st
//
//  Created by spearhead on 2015. 1. 21..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#ifndef CPVideo_CPPredefined_h
#define CPVideo_CPPredefined_h

#define UIKIT_NAVIGATIONBAR_DEFAULT_HEIGHT				44.f
#define UIKIT_STATUSBAR_DEFAULT_HEIGHT					20.f

#define CPListDefaultCount								30

#define CPPhotoClipMaxCount                             9

#define CPVideoLandscapeWidth							640.f
#define CPVideoLandscapeHeight							480.f
#define CPVideoPortraitWidth							480.f
#define CPVideoPortraitHeight							480.f

#define CPVideoMaximumDuration							30.f
#define CPVideoMinimumDuration							3.f
#define CPVideoMinimumClipDuration						1.f
#define CPVideo9x2ClipDuration							2.f
#define CPVideo6x3ClipDuration							3.f

#define CPVideoDefaultDateFormat						@"yyyy-MM-dd HH:mm:ss"
#define CPVideoMyVideoDateFormat						@"yyyy-MM-dd"
#define CPVideoListDateFormat							@"yyyy.MM.dd"

#define CPVideoRecorderDidSaveVideo                     @"CPVideoRecorderDidSaveVideo"

#define CPMovieItemDataKeyTitle                         @"title"
#define CPMovieItemDataKeyComment						@"comment"
#define CPMovieItemDataKeyCreatedAt                     @"created_at"
#define CPMovieItemDataKeyLastModifiedAt				@"last_modified_at"
#define CPMovieItemDataKeyWidth                         @"width"
#define CPMovieItemDataKeyHeight						@"height"
#define CPMovieItemDataKeyCoverImageURL                 @"cover_image_url"
#define CPMovieItemDataKeyWatermarkPosition             @"watermark_position"
#define CPMovieItemDataKeyFilterType					@"filter_type"
#define CPMovieItemDataKeyEncodingTime					@"encoding_time"
#define CPMovieItemDataKeyBGMTitle						@"bgm_title"
#define CPMovieItemDataKeyDuration						@"duration"

#define CPMovieMyVideoPlistFilename                     @"CPVideoMyVideo.plist"
#define CPMovieCompostionItemPlistFilename				@"CPVideoCompositionItem.plist"
#define CPMovieTemporaryExtension						@"11stVideo/Drafts"
#define CPMovieDocumentExtension						@"11stVideo/MyVideo"

#define CPMovieRecordClips								@"CPMovieRecordClips"
#define CPMovieRecordClipsNone							0
#define CPMovieRecordClips9x2							1
#define CPMovieRecordClips6x3							2 // default
#define CPMovieRecordClipsUserDefined					3
#define CPMovieRecordClipsCustom						4

#define CPMovieRecordClips9x2ClipCount					9
#define CPMovieRecordClips6x3ClipCount					6

#define CPMovieRecordUserDefinedClipCount				@"CPMovieRecordUserDefinedClipCount"
#define CPMovieRecordUserDefinedClipCountNone			0
#define CPMovieRecordUserDefinedClipCountMin			1
#define CPMovieRecordUserDefinedClipCountMax			30
#define CPMovieRecordUserDefinedClipCountDefault		6

#define CPMovieRecordUserDefinedClipDuration			@"CPMovieRecordUserDefinedClipDuration"
#define CPMovieRecordUserDefinedClipDurationNone		0
#define CPMovieRecordUserDefinedClipDurationMin         1
#define CPMovieRecordUserDefinedClipDurationMax         30
#define CPMovieRecordUserDefinedClipDurationDefault     3

#define CPMovieRecordCustomMaxDuration					@"CPMovieRecordCustomMaxDuration"
#define CPMovieRecordCustomMaxDurationNone				0
#define CPMovieRecordCustomMaxDurationMinimum			3
#define CPMovieRecordCustomMaxDurationMaximum			30
#define CPMovieRecordCustomMaxDurationDefault			30

#define CPMovieFrameSize								@"CPMovieFrameSize"
#define CPMovieFrameSize640x480                         0
#define CPMovieFrameSize480x480                         1

#define CPMovieWatermarkPosition						@"CPMovieWatermarkPosition"
#define CPMovieWatermarkPositionNone					0
#define CPMovieWatermarkPositionTopLeft                 1
#define CPMovieWatermarkPositionTopRight				2
#define CPMovieWatermarkPositionBottomLeft				3
#define CPMovieWatermarkPositionBottomRight             4

#define CPExitButtonEnabled                             @"CPExitButtonEnabled"
#define CPAutoScrollEnabled                             @"CPAutoScrollEnabled"

//#define CPMovieRecordTorch							@"CPMovieRecordTorch"

/* Asset keys */
#define CPMoviePlayerViewObserverTracksKey				@"tracks"
#define CPMoviePlayerViewObserverPlayableKey			@"playable"
#define CPMoviePlayerViewObserverStatusKey				@"status"
#define CPMoviePlayerViewObserverCurrentItemKey         @"currentItem"
#define CPMoviePlayerViewObserverRateKey				@"rate"
#define CPMoviePlayerLayerObserverReadyForDisplayKey	@"readyForDisplay"

/* Filter keys */
#define CPMovieFilterId                                 @"Id"
#define CPMovieFilterTitle								@"Title"
#define CPMovieFilterDescription						@"Description"
#define CPMovieFilterValueCurves						@"CURVES"
#define CPMovieFilterValueCurvesAll                     @"ALL"
#define CPMovieFilterValueCurvesRed                     @"R"
#define CPMovieFilterValueCurvesGreen					@"G"
#define CPMovieFilterValueCurvesBlue					@"B"
#define CPMovieFilterValueSaturation					@"SATURATION"
#define CPMovieFilterValueBrightness					@"BRIGHTNESS"
#define CPMovieFilterValueContrast						@"CONTRAST"
#define CPMovieFilterValueVignette						@"VIGNETTE"
#define CPMovieFilterValueName							@"NAME"
#define CPMovieFilterValueAlpha                         @"ALPHA"
#define CPMovieFilterVaueBWMode                         @"BWMODE"

/* Notification keys */
#define CPVideoEncodingEndedNotification				@"CPVideoEncodingEndedNotification"
#define CPDraftCompositionItemCalledNotification		@"CPDraftCompositionItemCalledNotification"

/* Draft keys */
#define CPDraftCompositionItemKeyClips					@"clips"
#define CPDraftCompositionItemKeyWatermark				@"watermark"
#define CPDraftCompositionItemKeyFrameSize				@"frame_size"
#define CPDraftCompositionItemKeyRecordType             @"record_type"
#define CPDraftCompositionItemKeyClipMaxCount			@"clip_max_count"
#define CPDraftCompositionItemKeyClipMaxDuration		@"clip_max_duration"
#define CPDraftCompositionItemKeyClipTotalDuration		@"clip_total_duration"

/* Et cetera keys... */
#define CPUserDefaultsDeviceIdentifierKey				@"identifier"

#endif