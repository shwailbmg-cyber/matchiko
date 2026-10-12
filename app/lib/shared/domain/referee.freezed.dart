// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefJob {

 String get bookingId; DateTime get startsAt; String get venue; int get perSide;/// Set once the game exists (needed for the match report).
 String? get gameId; bool get mine; bool get reported;
/// Create a copy of RefJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefJobCopyWith<RefJob> get copyWith => _$RefJobCopyWithImpl<RefJob>(this as RefJob, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RefJob;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefJob&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.perSide, _this.perSide) || other.perSide == _this.perSide)&&(identical(other.gameId, _this.gameId) || other.gameId == _this.gameId)&&(identical(other.mine, _this.mine) || other.mine == _this.mine)&&(identical(other.reported, _this.reported) || other.reported == _this.reported));
}


@override
int get hashCode {
  final _this = this as RefJob;
  return Object.hash(runtimeType,_this.bookingId,_this.startsAt,_this.venue,_this.perSide,_this.gameId,_this.mine,_this.reported);
}

@override
String toString() {
  final _this = this as RefJob;
  return 'RefJob(bookingId: ${_this.bookingId}, startsAt: ${_this.startsAt}, venue: ${_this.venue}, perSide: ${_this.perSide}, gameId: ${_this.gameId}, mine: ${_this.mine}, reported: ${_this.reported})';
}


}

/// @nodoc
abstract mixin class $RefJobCopyWith<$Res>  {
  factory $RefJobCopyWith(RefJob value, $Res Function(RefJob) _then) = _$RefJobCopyWithImpl;
@useResult
$Res call({
 String bookingId, DateTime startsAt, String venue, int perSide, String? gameId, bool mine, bool reported
});




}
/// @nodoc
class _$RefJobCopyWithImpl<$Res>
    implements $RefJobCopyWith<$Res> {
  _$RefJobCopyWithImpl(this._self, this._then);

  final RefJob _self;
  final $Res Function(RefJob) _then;

/// Create a copy of RefJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? startsAt = null,Object? venue = null,Object? perSide = null,Object? gameId = freezed,Object? mine = null,Object? reported = null,}) {
  return _then(RefJob(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RefJob].
extension RefJobPatterns on RefJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefJob value)  $default,){
final _that = this;
switch (_that) {
case _RefJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefJob value)?  $default,){
final _that = this;
switch (_that) {
case _RefJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  DateTime startsAt,  String venue,  int perSide,  String? gameId,  bool mine,  bool reported)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefJob() when $default != null:
return $default(_that.bookingId,_that.startsAt,_that.venue,_that.perSide,_that.gameId,_that.mine,_that.reported);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  DateTime startsAt,  String venue,  int perSide,  String? gameId,  bool mine,  bool reported)  $default,) {final _that = this;
switch (_that) {
case _RefJob():
return $default(_that.bookingId,_that.startsAt,_that.venue,_that.perSide,_that.gameId,_that.mine,_that.reported);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  DateTime startsAt,  String venue,  int perSide,  String? gameId,  bool mine,  bool reported)?  $default,) {final _that = this;
switch (_that) {
case _RefJob() when $default != null:
return $default(_that.bookingId,_that.startsAt,_that.venue,_that.perSide,_that.gameId,_that.mine,_that.reported);case _:
  return null;

}
}

}

/// @nodoc


class _RefJob extends RefJob {
  const _RefJob({required this.bookingId, required this.startsAt, required this.venue, required this.perSide, this.gameId, this.mine = false, this.reported = false}): super._();
  

@override final  String bookingId;
@override final  DateTime startsAt;
@override final  String venue;
@override final  int perSide;
/// Set once the game exists (needed for the match report).
@override final  String? gameId;
@override@JsonKey() final  bool mine;
@override@JsonKey() final  bool reported;

/// Create a copy of RefJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefJobCopyWith<_RefJob> get copyWith => __$RefJobCopyWithImpl<_RefJob>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefJob&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.perSide, perSide) || other.perSide == perSide)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.mine, mine) || other.mine == mine)&&(identical(other.reported, reported) || other.reported == reported));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,startsAt,venue,perSide,gameId,mine,reported);
}

@override
String toString() {
    return 'RefJob(bookingId: $bookingId, startsAt: $startsAt, venue: $venue, perSide: $perSide, gameId: $gameId, mine: $mine, reported: $reported)';
}


}

/// @nodoc
abstract mixin class _$RefJobCopyWith<$Res> implements $RefJobCopyWith<$Res> {
  factory _$RefJobCopyWith(_RefJob value, $Res Function(_RefJob) _then) = __$RefJobCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, DateTime startsAt, String venue, int perSide, String? gameId, bool mine, bool reported
});




}
/// @nodoc
class __$RefJobCopyWithImpl<$Res>
    implements _$RefJobCopyWith<$Res> {
  __$RefJobCopyWithImpl(this._self, this._then);

  final _RefJob _self;
  final $Res Function(_RefJob) _then;

/// Create a copy of RefJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? startsAt = null,Object? venue = null,Object? perSide = null,Object? gameId = freezed,Object? mine = null,Object? reported = null,}) {
  return _then(_RefJob(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RefAvailability {

 int get weekday; int get startHour; int get endHour;
/// Create a copy of RefAvailability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefAvailabilityCopyWith<RefAvailability> get copyWith => _$RefAvailabilityCopyWithImpl<RefAvailability>(this as RefAvailability, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RefAvailability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefAvailability&&(identical(other.weekday, _this.weekday) || other.weekday == _this.weekday)&&(identical(other.startHour, _this.startHour) || other.startHour == _this.startHour)&&(identical(other.endHour, _this.endHour) || other.endHour == _this.endHour));
}


@override
int get hashCode {
  final _this = this as RefAvailability;
  return Object.hash(runtimeType,_this.weekday,_this.startHour,_this.endHour);
}

@override
String toString() {
  final _this = this as RefAvailability;
  return 'RefAvailability(weekday: ${_this.weekday}, startHour: ${_this.startHour}, endHour: ${_this.endHour})';
}


}

/// @nodoc
abstract mixin class $RefAvailabilityCopyWith<$Res>  {
  factory $RefAvailabilityCopyWith(RefAvailability value, $Res Function(RefAvailability) _then) = _$RefAvailabilityCopyWithImpl;
@useResult
$Res call({
 int weekday, int startHour, int endHour
});




}
/// @nodoc
class _$RefAvailabilityCopyWithImpl<$Res>
    implements $RefAvailabilityCopyWith<$Res> {
  _$RefAvailabilityCopyWithImpl(this._self, this._then);

  final RefAvailability _self;
  final $Res Function(RefAvailability) _then;

/// Create a copy of RefAvailability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? startHour = null,Object? endHour = null,}) {
  return _then(RefAvailability(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RefAvailability].
extension RefAvailabilityPatterns on RefAvailability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefAvailability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefAvailability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefAvailability value)  $default,){
final _that = this;
switch (_that) {
case _RefAvailability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefAvailability value)?  $default,){
final _that = this;
switch (_that) {
case _RefAvailability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekday,  int startHour,  int endHour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefAvailability() when $default != null:
return $default(_that.weekday,_that.startHour,_that.endHour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekday,  int startHour,  int endHour)  $default,) {final _that = this;
switch (_that) {
case _RefAvailability():
return $default(_that.weekday,_that.startHour,_that.endHour);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekday,  int startHour,  int endHour)?  $default,) {final _that = this;
switch (_that) {
case _RefAvailability() when $default != null:
return $default(_that.weekday,_that.startHour,_that.endHour);case _:
  return null;

}
}

}

/// @nodoc


class _RefAvailability implements RefAvailability {
  const _RefAvailability({required this.weekday, required this.startHour, required this.endHour});
  

@override final  int weekday;
@override final  int startHour;
@override final  int endHour;

/// Create a copy of RefAvailability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefAvailabilityCopyWith<_RefAvailability> get copyWith => __$RefAvailabilityCopyWithImpl<_RefAvailability>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefAvailability&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,weekday,startHour,endHour);
}

@override
String toString() {
    return 'RefAvailability(weekday: $weekday, startHour: $startHour, endHour: $endHour)';
}


}

/// @nodoc
abstract mixin class _$RefAvailabilityCopyWith<$Res> implements $RefAvailabilityCopyWith<$Res> {
  factory _$RefAvailabilityCopyWith(_RefAvailability value, $Res Function(_RefAvailability) _then) = __$RefAvailabilityCopyWithImpl;
@override @useResult
$Res call({
 int weekday, int startHour, int endHour
});




}
/// @nodoc
class __$RefAvailabilityCopyWithImpl<$Res>
    implements _$RefAvailabilityCopyWith<$Res> {
  __$RefAvailabilityCopyWithImpl(this._self, this._then);

  final _RefAvailability _self;
  final $Res Function(_RefAvailability) _then;

/// Create a copy of RefAvailability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? startHour = null,Object? endHour = null,}) {
  return _then(_RefAvailability(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as int,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MatchEvent {

 MatchEventType get type; Side get side; String get handle;
/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchEventCopyWith<MatchEvent> get copyWith => _$MatchEventCopyWithImpl<MatchEvent>(this as MatchEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchEvent&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.handle, _this.handle) || other.handle == _this.handle));
}


@override
int get hashCode {
  final _this = this as MatchEvent;
  return Object.hash(runtimeType,_this.type,_this.side,_this.handle);
}

@override
String toString() {
  final _this = this as MatchEvent;
  return 'MatchEvent(type: ${_this.type}, side: ${_this.side}, handle: ${_this.handle})';
}


}

/// @nodoc
abstract mixin class $MatchEventCopyWith<$Res>  {
  factory $MatchEventCopyWith(MatchEvent value, $Res Function(MatchEvent) _then) = _$MatchEventCopyWithImpl;
@useResult
$Res call({
 MatchEventType type, Side side, String handle
});




}
/// @nodoc
class _$MatchEventCopyWithImpl<$Res>
    implements $MatchEventCopyWith<$Res> {
  _$MatchEventCopyWithImpl(this._self, this._then);

  final MatchEvent _self;
  final $Res Function(MatchEvent) _then;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? side = null,Object? handle = null,}) {
  return _then(MatchEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchEventType,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as Side,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchEvent].
extension MatchEventPatterns on MatchEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchEvent value)  $default,){
final _that = this;
switch (_that) {
case _MatchEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchEvent value)?  $default,){
final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MatchEventType type,  Side side,  String handle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
return $default(_that.type,_that.side,_that.handle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MatchEventType type,  Side side,  String handle)  $default,) {final _that = this;
switch (_that) {
case _MatchEvent():
return $default(_that.type,_that.side,_that.handle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MatchEventType type,  Side side,  String handle)?  $default,) {final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
return $default(_that.type,_that.side,_that.handle);case _:
  return null;

}
}

}

/// @nodoc


class _MatchEvent implements MatchEvent {
  const _MatchEvent({required this.type, required this.side, required this.handle});
  

@override final  MatchEventType type;
@override final  Side side;
@override final  String handle;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchEventCopyWith<_MatchEvent> get copyWith => __$MatchEventCopyWithImpl<_MatchEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.side, side) || other.side == side)&&(identical(other.handle, handle) || other.handle == handle));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,side,handle);
}

@override
String toString() {
    return 'MatchEvent(type: $type, side: $side, handle: $handle)';
}


}

/// @nodoc
abstract mixin class _$MatchEventCopyWith<$Res> implements $MatchEventCopyWith<$Res> {
  factory _$MatchEventCopyWith(_MatchEvent value, $Res Function(_MatchEvent) _then) = __$MatchEventCopyWithImpl;
@override @useResult
$Res call({
 MatchEventType type, Side side, String handle
});




}
/// @nodoc
class __$MatchEventCopyWithImpl<$Res>
    implements _$MatchEventCopyWith<$Res> {
  __$MatchEventCopyWithImpl(this._self, this._then);

  final _MatchEvent _self;
  final $Res Function(_MatchEvent) _then;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? side = null,Object? handle = null,}) {
  return _then(_MatchEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchEventType,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as Side,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
