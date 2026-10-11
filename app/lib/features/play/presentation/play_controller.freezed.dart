// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayState {

 PlayMode get mode;/// Tap order = preference order.
 List<Position> get positions; int get day; Set<TimeWindow> get windows; double get radiusKm; bool get referee; PlayStage get stage;/// Searching animation step, 0..4.
 int get step; int get secondsLeft; Game? get offer;
/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayStateCopyWith<PlayState> get copyWith => _$PlayStateCopyWithImpl<PlayState>(this as PlayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayState&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.positions, _this.positions)&&(identical(other.day, _this.day) || other.day == _this.day)&&const DeepCollectionEquality().equals(other.windows, _this.windows)&&(identical(other.radiusKm, _this.radiusKm) || other.radiusKm == _this.radiusKm)&&(identical(other.referee, _this.referee) || other.referee == _this.referee)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.secondsLeft, _this.secondsLeft) || other.secondsLeft == _this.secondsLeft)&&(identical(other.offer, _this.offer) || other.offer == _this.offer));
}


@override
int get hashCode {
  final _this = this as PlayState;
  return Object.hash(runtimeType,_this.mode,const DeepCollectionEquality().hash(_this.positions),_this.day,const DeepCollectionEquality().hash(_this.windows),_this.radiusKm,_this.referee,_this.stage,_this.step,_this.secondsLeft,_this.offer);
}

@override
String toString() {
  final _this = this as PlayState;
  return 'PlayState(mode: ${_this.mode}, positions: ${_this.positions}, day: ${_this.day}, windows: ${_this.windows}, radiusKm: ${_this.radiusKm}, referee: ${_this.referee}, stage: ${_this.stage}, step: ${_this.step}, secondsLeft: ${_this.secondsLeft}, offer: ${_this.offer})';
}


}

/// @nodoc
abstract mixin class $PlayStateCopyWith<$Res>  {
  factory $PlayStateCopyWith(PlayState value, $Res Function(PlayState) _then) = _$PlayStateCopyWithImpl;
@useResult
$Res call({
 PlayMode mode, List<Position> positions, int day, Set<TimeWindow> windows, double radiusKm, bool referee, PlayStage stage, int step, int secondsLeft, Game? offer
});


$GameCopyWith<$Res>? get offer;

}
/// @nodoc
class _$PlayStateCopyWithImpl<$Res>
    implements $PlayStateCopyWith<$Res> {
  _$PlayStateCopyWithImpl(this._self, this._then);

  final PlayState _self;
  final $Res Function(PlayState) _then;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? positions = null,Object? day = null,Object? windows = null,Object? radiusKm = null,Object? referee = null,Object? stage = null,Object? step = null,Object? secondsLeft = null,Object? offer = freezed,}) {
  return _then(PlayState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PlayMode,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,windows: null == windows ? _self.windows : windows // ignore: cast_nullable_to_non_nullable
as Set<TimeWindow>,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double,referee: null == referee ? _self.referee : referee // ignore: cast_nullable_to_non_nullable
as bool,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PlayStage,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,secondsLeft: null == secondsLeft ? _self.secondsLeft : secondsLeft // ignore: cast_nullable_to_non_nullable
as int,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as Game?,
  ));
}
/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $GameCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayState].
extension PlayStatePatterns on PlayState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayState value)  $default,){
final _that = this;
switch (_that) {
case _PlayState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayMode mode,  List<Position> positions,  int day,  Set<TimeWindow> windows,  double radiusKm,  bool referee,  PlayStage stage,  int step,  int secondsLeft,  Game? offer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that.mode,_that.positions,_that.day,_that.windows,_that.radiusKm,_that.referee,_that.stage,_that.step,_that.secondsLeft,_that.offer);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayMode mode,  List<Position> positions,  int day,  Set<TimeWindow> windows,  double radiusKm,  bool referee,  PlayStage stage,  int step,  int secondsLeft,  Game? offer)  $default,) {final _that = this;
switch (_that) {
case _PlayState():
return $default(_that.mode,_that.positions,_that.day,_that.windows,_that.radiusKm,_that.referee,_that.stage,_that.step,_that.secondsLeft,_that.offer);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayMode mode,  List<Position> positions,  int day,  Set<TimeWindow> windows,  double radiusKm,  bool referee,  PlayStage stage,  int step,  int secondsLeft,  Game? offer)?  $default,) {final _that = this;
switch (_that) {
case _PlayState() when $default != null:
return $default(_that.mode,_that.positions,_that.day,_that.windows,_that.radiusKm,_that.referee,_that.stage,_that.step,_that.secondsLeft,_that.offer);case _:
  return null;

}
}

}

/// @nodoc


class _PlayState implements PlayState {
  const _PlayState({this.mode = PlayMode.solo,  List<Position> positions = const [Position.mid, Position.fwd], this.day = 0,  Set<TimeWindow> windows = const {TimeWindow.evening}, this.radiusKm = 5, this.referee = false, this.stage = PlayStage.form, this.step = 0, this.secondsLeft = 0, this.offer}): _positions = positions,_windows = windows;
  

@override@JsonKey() final  PlayMode mode;
/// Tap order = preference order.
 final  List<Position> _positions;
/// Tap order = preference order.
@override@JsonKey() List<Position> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}

@override@JsonKey() final  int day;
 final  Set<TimeWindow> _windows;
@override@JsonKey() Set<TimeWindow> get windows {
  if (_windows is EqualUnmodifiableSetView) return _windows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_windows);
}

@override@JsonKey() final  double radiusKm;
@override@JsonKey() final  bool referee;
@override@JsonKey() final  PlayStage stage;
/// Searching animation step, 0..4.
@override@JsonKey() final  int step;
@override@JsonKey() final  int secondsLeft;
@override final  Game? offer;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayStateCopyWith<_PlayState> get copyWith => __$PlayStateCopyWithImpl<_PlayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayState&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.positions, _positions)&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other.windows, _windows)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.referee, referee) || other.referee == referee)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.step, step) || other.step == step)&&(identical(other.secondsLeft, secondsLeft) || other.secondsLeft == secondsLeft)&&(identical(other.offer, offer) || other.offer == offer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,const DeepCollectionEquality().hash(_positions),day,const DeepCollectionEquality().hash(_windows),radiusKm,referee,stage,step,secondsLeft,offer);
}

@override
String toString() {
    return 'PlayState(mode: $mode, positions: $positions, day: $day, windows: $windows, radiusKm: $radiusKm, referee: $referee, stage: $stage, step: $step, secondsLeft: $secondsLeft, offer: $offer)';
}


}

/// @nodoc
abstract mixin class _$PlayStateCopyWith<$Res> implements $PlayStateCopyWith<$Res> {
  factory _$PlayStateCopyWith(_PlayState value, $Res Function(_PlayState) _then) = __$PlayStateCopyWithImpl;
@override @useResult
$Res call({
 PlayMode mode, List<Position> positions, int day, Set<TimeWindow> windows, double radiusKm, bool referee, PlayStage stage, int step, int secondsLeft, Game? offer
});


@override $GameCopyWith<$Res>? get offer;

}
/// @nodoc
class __$PlayStateCopyWithImpl<$Res>
    implements _$PlayStateCopyWith<$Res> {
  __$PlayStateCopyWithImpl(this._self, this._then);

  final _PlayState _self;
  final $Res Function(_PlayState) _then;

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? positions = null,Object? day = null,Object? windows = null,Object? radiusKm = null,Object? referee = null,Object? stage = null,Object? step = null,Object? secondsLeft = null,Object? offer = freezed,}) {
  return _then(_PlayState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PlayMode,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,windows: null == windows ? _self._windows : windows // ignore: cast_nullable_to_non_nullable
as Set<TimeWindow>,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double,referee: null == referee ? _self.referee : referee // ignore: cast_nullable_to_non_nullable
as bool,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PlayStage,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,secondsLeft: null == secondsLeft ? _self.secondsLeft : secondsLeft // ignore: cast_nullable_to_non_nullable
as int,offer: freezed == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as Game?,
  ));
}

/// Create a copy of PlayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameCopyWith<$Res>? get offer {
    if (_self.offer == null) {
    return null;
  }

  return $GameCopyWith<$Res>(_self.offer!, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}

// dart format on
