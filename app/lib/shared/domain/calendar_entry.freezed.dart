// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarEntry {

 String get id; DateTime get startsAt; CalendarKind get kind;/// Booker name, block reason or walk-in customer name.
 String get label; String? get phone; BookingStatus? get status; String? get gameId;
/// Create a copy of CalendarEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEntryCopyWith<CalendarEntry> get copyWith => _$CalendarEntryCopyWithImpl<CalendarEntry>(this as CalendarEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.gameId, _this.gameId) || other.gameId == _this.gameId));
}


@override
int get hashCode {
  final _this = this as CalendarEntry;
  return Object.hash(runtimeType,_this.id,_this.startsAt,_this.kind,_this.label,_this.phone,_this.status,_this.gameId);
}

@override
String toString() {
  final _this = this as CalendarEntry;
  return 'CalendarEntry(id: ${_this.id}, startsAt: ${_this.startsAt}, kind: ${_this.kind}, label: ${_this.label}, phone: ${_this.phone}, status: ${_this.status}, gameId: ${_this.gameId})';
}


}

/// @nodoc
abstract mixin class $CalendarEntryCopyWith<$Res>  {
  factory $CalendarEntryCopyWith(CalendarEntry value, $Res Function(CalendarEntry) _then) = _$CalendarEntryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startsAt, CalendarKind kind, String label, String? phone, BookingStatus? status, String? gameId
});




}
/// @nodoc
class _$CalendarEntryCopyWithImpl<$Res>
    implements $CalendarEntryCopyWith<$Res> {
  _$CalendarEntryCopyWithImpl(this._self, this._then);

  final CalendarEntry _self;
  final $Res Function(CalendarEntry) _then;

/// Create a copy of CalendarEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startsAt = null,Object? kind = null,Object? label = null,Object? phone = freezed,Object? status = freezed,Object? gameId = freezed,}) {
  return _then(CalendarEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CalendarKind,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarEntry].
extension CalendarEntryPatterns on CalendarEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEntry value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startsAt,  CalendarKind kind,  String label,  String? phone,  BookingStatus? status,  String? gameId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEntry() when $default != null:
return $default(_that.id,_that.startsAt,_that.kind,_that.label,_that.phone,_that.status,_that.gameId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startsAt,  CalendarKind kind,  String label,  String? phone,  BookingStatus? status,  String? gameId)  $default,) {final _that = this;
switch (_that) {
case _CalendarEntry():
return $default(_that.id,_that.startsAt,_that.kind,_that.label,_that.phone,_that.status,_that.gameId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startsAt,  CalendarKind kind,  String label,  String? phone,  BookingStatus? status,  String? gameId)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEntry() when $default != null:
return $default(_that.id,_that.startsAt,_that.kind,_that.label,_that.phone,_that.status,_that.gameId);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarEntry implements CalendarEntry {
  const _CalendarEntry({required this.id, required this.startsAt, required this.kind, this.label = '', this.phone, this.status, this.gameId});
  

@override final  String id;
@override final  DateTime startsAt;
@override final  CalendarKind kind;
/// Booker name, block reason or walk-in customer name.
@override@JsonKey() final  String label;
@override final  String? phone;
@override final  BookingStatus? status;
@override final  String? gameId;

/// Create a copy of CalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEntryCopyWith<_CalendarEntry> get copyWith => __$CalendarEntryCopyWithImpl<_CalendarEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameId, gameId) || other.gameId == gameId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,startsAt,kind,label,phone,status,gameId);
}

@override
String toString() {
    return 'CalendarEntry(id: $id, startsAt: $startsAt, kind: $kind, label: $label, phone: $phone, status: $status, gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class _$CalendarEntryCopyWith<$Res> implements $CalendarEntryCopyWith<$Res> {
  factory _$CalendarEntryCopyWith(_CalendarEntry value, $Res Function(_CalendarEntry) _then) = __$CalendarEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startsAt, CalendarKind kind, String label, String? phone, BookingStatus? status, String? gameId
});




}
/// @nodoc
class __$CalendarEntryCopyWithImpl<$Res>
    implements _$CalendarEntryCopyWith<$Res> {
  __$CalendarEntryCopyWithImpl(this._self, this._then);

  final _CalendarEntry _self;
  final $Res Function(_CalendarEntry) _then;

/// Create a copy of CalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startsAt = null,Object? kind = null,Object? label = null,Object? phone = freezed,Object? status = freezed,Object? gameId = freezed,}) {
  return _then(_CalendarEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CalendarKind,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
