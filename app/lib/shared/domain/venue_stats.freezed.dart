// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueStats {

 int get bookings; int get requested; int get confirmed; int get guaranteed; int get completed; int get cancelled; int get noShows; int get walkIns; int get cashExpectedDa; int get cashReceivedDa; int get bookedHours; int get openHours;
/// Create a copy of VenueStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueStatsCopyWith<VenueStats> get copyWith => _$VenueStatsCopyWithImpl<VenueStats>(this as VenueStats, _$identity);

  /// Serializes this VenueStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VenueStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueStats&&(identical(other.bookings, _this.bookings) || other.bookings == _this.bookings)&&(identical(other.requested, _this.requested) || other.requested == _this.requested)&&(identical(other.confirmed, _this.confirmed) || other.confirmed == _this.confirmed)&&(identical(other.guaranteed, _this.guaranteed) || other.guaranteed == _this.guaranteed)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.cancelled, _this.cancelled) || other.cancelled == _this.cancelled)&&(identical(other.noShows, _this.noShows) || other.noShows == _this.noShows)&&(identical(other.walkIns, _this.walkIns) || other.walkIns == _this.walkIns)&&(identical(other.cashExpectedDa, _this.cashExpectedDa) || other.cashExpectedDa == _this.cashExpectedDa)&&(identical(other.cashReceivedDa, _this.cashReceivedDa) || other.cashReceivedDa == _this.cashReceivedDa)&&(identical(other.bookedHours, _this.bookedHours) || other.bookedHours == _this.bookedHours)&&(identical(other.openHours, _this.openHours) || other.openHours == _this.openHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VenueStats;
  return Object.hash(runtimeType,_this.bookings,_this.requested,_this.confirmed,_this.guaranteed,_this.completed,_this.cancelled,_this.noShows,_this.walkIns,_this.cashExpectedDa,_this.cashReceivedDa,_this.bookedHours,_this.openHours);
}

@override
String toString() {
  final _this = this as VenueStats;
  return 'VenueStats(bookings: ${_this.bookings}, requested: ${_this.requested}, confirmed: ${_this.confirmed}, guaranteed: ${_this.guaranteed}, completed: ${_this.completed}, cancelled: ${_this.cancelled}, noShows: ${_this.noShows}, walkIns: ${_this.walkIns}, cashExpectedDa: ${_this.cashExpectedDa}, cashReceivedDa: ${_this.cashReceivedDa}, bookedHours: ${_this.bookedHours}, openHours: ${_this.openHours})';
}


}

/// @nodoc
abstract mixin class $VenueStatsCopyWith<$Res>  {
  factory $VenueStatsCopyWith(VenueStats value, $Res Function(VenueStats) _then) = _$VenueStatsCopyWithImpl;
@useResult
$Res call({
 int bookings, int requested, int confirmed, int guaranteed, int completed, int cancelled, int noShows, int walkIns, int cashExpectedDa, int cashReceivedDa, int bookedHours, int openHours
});




}
/// @nodoc
class _$VenueStatsCopyWithImpl<$Res>
    implements $VenueStatsCopyWith<$Res> {
  _$VenueStatsCopyWithImpl(this._self, this._then);

  final VenueStats _self;
  final $Res Function(VenueStats) _then;

/// Create a copy of VenueStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookings = null,Object? requested = null,Object? confirmed = null,Object? guaranteed = null,Object? completed = null,Object? cancelled = null,Object? noShows = null,Object? walkIns = null,Object? cashExpectedDa = null,Object? cashReceivedDa = null,Object? bookedHours = null,Object? openHours = null,}) {
  return _then(VenueStats(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,requested: null == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,guaranteed: null == guaranteed ? _self.guaranteed : guaranteed // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,noShows: null == noShows ? _self.noShows : noShows // ignore: cast_nullable_to_non_nullable
as int,walkIns: null == walkIns ? _self.walkIns : walkIns // ignore: cast_nullable_to_non_nullable
as int,cashExpectedDa: null == cashExpectedDa ? _self.cashExpectedDa : cashExpectedDa // ignore: cast_nullable_to_non_nullable
as int,cashReceivedDa: null == cashReceivedDa ? _self.cashReceivedDa : cashReceivedDa // ignore: cast_nullable_to_non_nullable
as int,bookedHours: null == bookedHours ? _self.bookedHours : bookedHours // ignore: cast_nullable_to_non_nullable
as int,openHours: null == openHours ? _self.openHours : openHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueStats].
extension VenueStatsPatterns on VenueStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueStats value)  $default,){
final _that = this;
switch (_that) {
case _VenueStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueStats value)?  $default,){
final _that = this;
switch (_that) {
case _VenueStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookings,  int requested,  int confirmed,  int guaranteed,  int completed,  int cancelled,  int noShows,  int walkIns,  int cashExpectedDa,  int cashReceivedDa,  int bookedHours,  int openHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueStats() when $default != null:
return $default(_that.bookings,_that.requested,_that.confirmed,_that.guaranteed,_that.completed,_that.cancelled,_that.noShows,_that.walkIns,_that.cashExpectedDa,_that.cashReceivedDa,_that.bookedHours,_that.openHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookings,  int requested,  int confirmed,  int guaranteed,  int completed,  int cancelled,  int noShows,  int walkIns,  int cashExpectedDa,  int cashReceivedDa,  int bookedHours,  int openHours)  $default,) {final _that = this;
switch (_that) {
case _VenueStats():
return $default(_that.bookings,_that.requested,_that.confirmed,_that.guaranteed,_that.completed,_that.cancelled,_that.noShows,_that.walkIns,_that.cashExpectedDa,_that.cashReceivedDa,_that.bookedHours,_that.openHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookings,  int requested,  int confirmed,  int guaranteed,  int completed,  int cancelled,  int noShows,  int walkIns,  int cashExpectedDa,  int cashReceivedDa,  int bookedHours,  int openHours)?  $default,) {final _that = this;
switch (_that) {
case _VenueStats() when $default != null:
return $default(_that.bookings,_that.requested,_that.confirmed,_that.guaranteed,_that.completed,_that.cancelled,_that.noShows,_that.walkIns,_that.cashExpectedDa,_that.cashReceivedDa,_that.bookedHours,_that.openHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VenueStats extends VenueStats {
  const _VenueStats({this.bookings = 0, this.requested = 0, this.confirmed = 0, this.guaranteed = 0, this.completed = 0, this.cancelled = 0, this.noShows = 0, this.walkIns = 0, this.cashExpectedDa = 0, this.cashReceivedDa = 0, this.bookedHours = 0, this.openHours = 0}): super._();
  factory _VenueStats.fromJson(Map<String, dynamic> json) => _$VenueStatsFromJson(json);

@override@JsonKey() final  int bookings;
@override@JsonKey() final  int requested;
@override@JsonKey() final  int confirmed;
@override@JsonKey() final  int guaranteed;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int cancelled;
@override@JsonKey() final  int noShows;
@override@JsonKey() final  int walkIns;
@override@JsonKey() final  int cashExpectedDa;
@override@JsonKey() final  int cashReceivedDa;
@override@JsonKey() final  int bookedHours;
@override@JsonKey() final  int openHours;

/// Create a copy of VenueStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueStatsCopyWith<_VenueStats> get copyWith => __$VenueStatsCopyWithImpl<_VenueStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueStats&&(identical(other.bookings, bookings) || other.bookings == bookings)&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.guaranteed, guaranteed) || other.guaranteed == guaranteed)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.noShows, noShows) || other.noShows == noShows)&&(identical(other.walkIns, walkIns) || other.walkIns == walkIns)&&(identical(other.cashExpectedDa, cashExpectedDa) || other.cashExpectedDa == cashExpectedDa)&&(identical(other.cashReceivedDa, cashReceivedDa) || other.cashReceivedDa == cashReceivedDa)&&(identical(other.bookedHours, bookedHours) || other.bookedHours == bookedHours)&&(identical(other.openHours, openHours) || other.openHours == openHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookings,requested,confirmed,guaranteed,completed,cancelled,noShows,walkIns,cashExpectedDa,cashReceivedDa,bookedHours,openHours);
}

@override
String toString() {
    return 'VenueStats(bookings: $bookings, requested: $requested, confirmed: $confirmed, guaranteed: $guaranteed, completed: $completed, cancelled: $cancelled, noShows: $noShows, walkIns: $walkIns, cashExpectedDa: $cashExpectedDa, cashReceivedDa: $cashReceivedDa, bookedHours: $bookedHours, openHours: $openHours)';
}


}

/// @nodoc
abstract mixin class _$VenueStatsCopyWith<$Res> implements $VenueStatsCopyWith<$Res> {
  factory _$VenueStatsCopyWith(_VenueStats value, $Res Function(_VenueStats) _then) = __$VenueStatsCopyWithImpl;
@override @useResult
$Res call({
 int bookings, int requested, int confirmed, int guaranteed, int completed, int cancelled, int noShows, int walkIns, int cashExpectedDa, int cashReceivedDa, int bookedHours, int openHours
});




}
/// @nodoc
class __$VenueStatsCopyWithImpl<$Res>
    implements _$VenueStatsCopyWith<$Res> {
  __$VenueStatsCopyWithImpl(this._self, this._then);

  final _VenueStats _self;
  final $Res Function(_VenueStats) _then;

/// Create a copy of VenueStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookings = null,Object? requested = null,Object? confirmed = null,Object? guaranteed = null,Object? completed = null,Object? cancelled = null,Object? noShows = null,Object? walkIns = null,Object? cashExpectedDa = null,Object? cashReceivedDa = null,Object? bookedHours = null,Object? openHours = null,}) {
  return _then(_VenueStats(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as int,requested: null == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,guaranteed: null == guaranteed ? _self.guaranteed : guaranteed // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,noShows: null == noShows ? _self.noShows : noShows // ignore: cast_nullable_to_non_nullable
as int,walkIns: null == walkIns ? _self.walkIns : walkIns // ignore: cast_nullable_to_non_nullable
as int,cashExpectedDa: null == cashExpectedDa ? _self.cashExpectedDa : cashExpectedDa // ignore: cast_nullable_to_non_nullable
as int,cashReceivedDa: null == cashReceivedDa ? _self.cashReceivedDa : cashReceivedDa // ignore: cast_nullable_to_non_nullable
as int,bookedHours: null == bookedHours ? _self.bookedHours : bookedHours // ignore: cast_nullable_to_non_nullable
as int,openHours: null == openHours ? _self.openHours : openHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StaffMember {

 String get handle; String get name; bool get isMe;
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<StaffMember> get copyWith => _$StaffMemberCopyWithImpl<StaffMember>(this as StaffMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StaffMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffMember&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isMe, _this.isMe) || other.isMe == _this.isMe));
}


@override
int get hashCode {
  final _this = this as StaffMember;
  return Object.hash(runtimeType,_this.handle,_this.name,_this.isMe);
}

@override
String toString() {
  final _this = this as StaffMember;
  return 'StaffMember(handle: ${_this.handle}, name: ${_this.name}, isMe: ${_this.isMe})';
}


}

/// @nodoc
abstract mixin class $StaffMemberCopyWith<$Res>  {
  factory $StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) _then) = _$StaffMemberCopyWithImpl;
@useResult
$Res call({
 String handle, String name, bool isMe
});




}
/// @nodoc
class _$StaffMemberCopyWithImpl<$Res>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._self, this._then);

  final StaffMember _self;
  final $Res Function(StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handle = null,Object? name = null,Object? isMe = null,}) {
  return _then(StaffMember(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffMember].
extension StaffMemberPatterns on StaffMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffMember value)  $default,){
final _that = this;
switch (_that) {
case _StaffMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffMember value)?  $default,){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String handle,  String name,  bool isMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.handle,_that.name,_that.isMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String handle,  String name,  bool isMe)  $default,) {final _that = this;
switch (_that) {
case _StaffMember():
return $default(_that.handle,_that.name,_that.isMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String handle,  String name,  bool isMe)?  $default,) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.handle,_that.name,_that.isMe);case _:
  return null;

}
}

}

/// @nodoc


class _StaffMember implements StaffMember {
  const _StaffMember({required this.handle, required this.name, this.isMe = false});
  

@override final  String handle;
@override final  String name;
@override@JsonKey() final  bool isMe;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffMemberCopyWith<_StaffMember> get copyWith => __$StaffMemberCopyWithImpl<_StaffMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffMember&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.isMe, isMe) || other.isMe == isMe));
}


@override
int get hashCode {
    return Object.hash(runtimeType,handle,name,isMe);
}

@override
String toString() {
    return 'StaffMember(handle: $handle, name: $name, isMe: $isMe)';
}


}

/// @nodoc
abstract mixin class _$StaffMemberCopyWith<$Res> implements $StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) _then) = __$StaffMemberCopyWithImpl;
@override @useResult
$Res call({
 String handle, String name, bool isMe
});




}
/// @nodoc
class __$StaffMemberCopyWithImpl<$Res>
    implements _$StaffMemberCopyWith<$Res> {
  __$StaffMemberCopyWithImpl(this._self, this._then);

  final _StaffMember _self;
  final $Res Function(_StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handle = null,Object? name = null,Object? isMe = null,}) {
  return _then(_StaffMember(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
