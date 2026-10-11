// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefApplication {

 String get id; Player get player;
/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefApplicationCopyWith<RefApplication> get copyWith => _$RefApplicationCopyWithImpl<RefApplication>(this as RefApplication, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RefApplication;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefApplication&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.player, _this.player) || other.player == _this.player));
}


@override
int get hashCode {
  final _this = this as RefApplication;
  return Object.hash(runtimeType,_this.id,_this.player);
}

@override
String toString() {
  final _this = this as RefApplication;
  return 'RefApplication(id: ${_this.id}, player: ${_this.player})';
}


}

/// @nodoc
abstract mixin class $RefApplicationCopyWith<$Res>  {
  factory $RefApplicationCopyWith(RefApplication value, $Res Function(RefApplication) _then) = _$RefApplicationCopyWithImpl;
@useResult
$Res call({
 String id, Player player
});


$PlayerCopyWith<$Res> get player;

}
/// @nodoc
class _$RefApplicationCopyWithImpl<$Res>
    implements $RefApplicationCopyWith<$Res> {
  _$RefApplicationCopyWithImpl(this._self, this._then);

  final RefApplication _self;
  final $Res Function(RefApplication) _then;

/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? player = null,}) {
  return _then(RefApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,
  ));
}
/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// Adds pattern-matching-related methods to [RefApplication].
extension RefApplicationPatterns on RefApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefApplication value)  $default,){
final _that = this;
switch (_that) {
case _RefApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefApplication value)?  $default,){
final _that = this;
switch (_that) {
case _RefApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Player player)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefApplication() when $default != null:
return $default(_that.id,_that.player);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Player player)  $default,) {final _that = this;
switch (_that) {
case _RefApplication():
return $default(_that.id,_that.player);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Player player)?  $default,) {final _that = this;
switch (_that) {
case _RefApplication() when $default != null:
return $default(_that.id,_that.player);case _:
  return null;

}
}

}

/// @nodoc


class _RefApplication implements RefApplication {
  const _RefApplication({required this.id, required this.player});
  

@override final  String id;
@override final  Player player;

/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefApplicationCopyWith<_RefApplication> get copyWith => __$RefApplicationCopyWithImpl<_RefApplication>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.player, player) || other.player == player));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,player);
}

@override
String toString() {
    return 'RefApplication(id: $id, player: $player)';
}


}

/// @nodoc
abstract mixin class _$RefApplicationCopyWith<$Res> implements $RefApplicationCopyWith<$Res> {
  factory _$RefApplicationCopyWith(_RefApplication value, $Res Function(_RefApplication) _then) = __$RefApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, Player player
});


@override $PlayerCopyWith<$Res> get player;

}
/// @nodoc
class __$RefApplicationCopyWithImpl<$Res>
    implements _$RefApplicationCopyWith<$Res> {
  __$RefApplicationCopyWithImpl(this._self, this._then);

  final _RefApplication _self;
  final $Res Function(_RefApplication) _then;

/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? player = null,}) {
  return _then(_RefApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,
  ));
}

/// Create a copy of RefApplication
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}

/// @nodoc
mixin _$VenueReport {

 int get id; String get reporterName; Player get reported; ReportReason get reason; String get note; DateTime get gameStartsAt;
/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueReportCopyWith<VenueReport> get copyWith => _$VenueReportCopyWithImpl<VenueReport>(this as VenueReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VenueReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.reporterName, _this.reporterName) || other.reporterName == _this.reporterName)&&(identical(other.reported, _this.reported) || other.reported == _this.reported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.gameStartsAt, _this.gameStartsAt) || other.gameStartsAt == _this.gameStartsAt));
}


@override
int get hashCode {
  final _this = this as VenueReport;
  return Object.hash(runtimeType,_this.id,_this.reporterName,_this.reported,_this.reason,_this.note,_this.gameStartsAt);
}

@override
String toString() {
  final _this = this as VenueReport;
  return 'VenueReport(id: ${_this.id}, reporterName: ${_this.reporterName}, reported: ${_this.reported}, reason: ${_this.reason}, note: ${_this.note}, gameStartsAt: ${_this.gameStartsAt})';
}


}

/// @nodoc
abstract mixin class $VenueReportCopyWith<$Res>  {
  factory $VenueReportCopyWith(VenueReport value, $Res Function(VenueReport) _then) = _$VenueReportCopyWithImpl;
@useResult
$Res call({
 int id, String reporterName, Player reported, ReportReason reason, String note, DateTime gameStartsAt
});


$PlayerCopyWith<$Res> get reported;

}
/// @nodoc
class _$VenueReportCopyWithImpl<$Res>
    implements $VenueReportCopyWith<$Res> {
  _$VenueReportCopyWithImpl(this._self, this._then);

  final VenueReport _self;
  final $Res Function(VenueReport) _then;

/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterName = null,Object? reported = null,Object? reason = null,Object? note = null,Object? gameStartsAt = null,}) {
  return _then(VenueReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reporterName: null == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String,reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as Player,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,gameStartsAt: null == gameStartsAt ? _self.gameStartsAt : gameStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get reported {
  
  return $PlayerCopyWith<$Res>(_self.reported, (value) {
    return _then(_self.copyWith(reported: value));
  });
}
}


/// Adds pattern-matching-related methods to [VenueReport].
extension VenueReportPatterns on VenueReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueReport value)  $default,){
final _that = this;
switch (_that) {
case _VenueReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueReport value)?  $default,){
final _that = this;
switch (_that) {
case _VenueReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String reporterName,  Player reported,  ReportReason reason,  String note,  DateTime gameStartsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueReport() when $default != null:
return $default(_that.id,_that.reporterName,_that.reported,_that.reason,_that.note,_that.gameStartsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String reporterName,  Player reported,  ReportReason reason,  String note,  DateTime gameStartsAt)  $default,) {final _that = this;
switch (_that) {
case _VenueReport():
return $default(_that.id,_that.reporterName,_that.reported,_that.reason,_that.note,_that.gameStartsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String reporterName,  Player reported,  ReportReason reason,  String note,  DateTime gameStartsAt)?  $default,) {final _that = this;
switch (_that) {
case _VenueReport() when $default != null:
return $default(_that.id,_that.reporterName,_that.reported,_that.reason,_that.note,_that.gameStartsAt);case _:
  return null;

}
}

}

/// @nodoc


class _VenueReport implements VenueReport {
  const _VenueReport({required this.id, required this.reporterName, required this.reported, required this.reason, this.note = '', required this.gameStartsAt});
  

@override final  int id;
@override final  String reporterName;
@override final  Player reported;
@override final  ReportReason reason;
@override@JsonKey() final  String note;
@override final  DateTime gameStartsAt;

/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueReportCopyWith<_VenueReport> get copyWith => __$VenueReportCopyWithImpl<_VenueReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.reported, reported) || other.reported == reported)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.gameStartsAt, gameStartsAt) || other.gameStartsAt == gameStartsAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,reporterName,reported,reason,note,gameStartsAt);
}

@override
String toString() {
    return 'VenueReport(id: $id, reporterName: $reporterName, reported: $reported, reason: $reason, note: $note, gameStartsAt: $gameStartsAt)';
}


}

/// @nodoc
abstract mixin class _$VenueReportCopyWith<$Res> implements $VenueReportCopyWith<$Res> {
  factory _$VenueReportCopyWith(_VenueReport value, $Res Function(_VenueReport) _then) = __$VenueReportCopyWithImpl;
@override @useResult
$Res call({
 int id, String reporterName, Player reported, ReportReason reason, String note, DateTime gameStartsAt
});


@override $PlayerCopyWith<$Res> get reported;

}
/// @nodoc
class __$VenueReportCopyWithImpl<$Res>
    implements _$VenueReportCopyWith<$Res> {
  __$VenueReportCopyWithImpl(this._self, this._then);

  final _VenueReport _self;
  final $Res Function(_VenueReport) _then;

/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterName = null,Object? reported = null,Object? reason = null,Object? note = null,Object? gameStartsAt = null,}) {
  return _then(_VenueReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reporterName: null == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String,reported: null == reported ? _self.reported : reported // ignore: cast_nullable_to_non_nullable
as Player,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,gameStartsAt: null == gameStartsAt ? _self.gameStartsAt : gameStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of VenueReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get reported {
  
  return $PlayerCopyWith<$Res>(_self.reported, (value) {
    return _then(_self.copyWith(reported: value));
  });
}
}

// dart format on
