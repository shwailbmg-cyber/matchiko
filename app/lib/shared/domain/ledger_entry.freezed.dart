// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LedgerEntry {

 RewardReason get reason; int get xpDelta; int get coinsDelta; DateTime get createdAt;
/// Create a copy of LedgerEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerEntryCopyWith<LedgerEntry> get copyWith => _$LedgerEntryCopyWithImpl<LedgerEntry>(this as LedgerEntry, _$identity);

  /// Serializes this LedgerEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LedgerEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerEntry&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.xpDelta, _this.xpDelta) || other.xpDelta == _this.xpDelta)&&(identical(other.coinsDelta, _this.coinsDelta) || other.coinsDelta == _this.coinsDelta)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LedgerEntry;
  return Object.hash(runtimeType,_this.reason,_this.xpDelta,_this.coinsDelta,_this.createdAt);
}

@override
String toString() {
  final _this = this as LedgerEntry;
  return 'LedgerEntry(reason: ${_this.reason}, xpDelta: ${_this.xpDelta}, coinsDelta: ${_this.coinsDelta}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $LedgerEntryCopyWith<$Res>  {
  factory $LedgerEntryCopyWith(LedgerEntry value, $Res Function(LedgerEntry) _then) = _$LedgerEntryCopyWithImpl;
@useResult
$Res call({
 RewardReason reason, int xpDelta, int coinsDelta, DateTime createdAt
});




}
/// @nodoc
class _$LedgerEntryCopyWithImpl<$Res>
    implements $LedgerEntryCopyWith<$Res> {
  _$LedgerEntryCopyWithImpl(this._self, this._then);

  final LedgerEntry _self;
  final $Res Function(LedgerEntry) _then;

/// Create a copy of LedgerEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? xpDelta = null,Object? coinsDelta = null,Object? createdAt = null,}) {
  return _then(LedgerEntry(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RewardReason,xpDelta: null == xpDelta ? _self.xpDelta : xpDelta // ignore: cast_nullable_to_non_nullable
as int,coinsDelta: null == coinsDelta ? _self.coinsDelta : coinsDelta // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerEntry].
extension LedgerEntryPatterns on LedgerEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerEntry value)  $default,){
final _that = this;
switch (_that) {
case _LedgerEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RewardReason reason,  int xpDelta,  int coinsDelta,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerEntry() when $default != null:
return $default(_that.reason,_that.xpDelta,_that.coinsDelta,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RewardReason reason,  int xpDelta,  int coinsDelta,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LedgerEntry():
return $default(_that.reason,_that.xpDelta,_that.coinsDelta,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RewardReason reason,  int xpDelta,  int coinsDelta,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LedgerEntry() when $default != null:
return $default(_that.reason,_that.xpDelta,_that.coinsDelta,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerEntry implements LedgerEntry {
  const _LedgerEntry({required this.reason, required this.xpDelta, required this.coinsDelta, required this.createdAt});
  factory _LedgerEntry.fromJson(Map<String, dynamic> json) => _$LedgerEntryFromJson(json);

@override final  RewardReason reason;
@override final  int xpDelta;
@override final  int coinsDelta;
@override final  DateTime createdAt;

/// Create a copy of LedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerEntryCopyWith<_LedgerEntry> get copyWith => __$LedgerEntryCopyWithImpl<_LedgerEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerEntry&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.xpDelta, xpDelta) || other.xpDelta == xpDelta)&&(identical(other.coinsDelta, coinsDelta) || other.coinsDelta == coinsDelta)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reason,xpDelta,coinsDelta,createdAt);
}

@override
String toString() {
    return 'LedgerEntry(reason: $reason, xpDelta: $xpDelta, coinsDelta: $coinsDelta, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LedgerEntryCopyWith<$Res> implements $LedgerEntryCopyWith<$Res> {
  factory _$LedgerEntryCopyWith(_LedgerEntry value, $Res Function(_LedgerEntry) _then) = __$LedgerEntryCopyWithImpl;
@override @useResult
$Res call({
 RewardReason reason, int xpDelta, int coinsDelta, DateTime createdAt
});




}
/// @nodoc
class __$LedgerEntryCopyWithImpl<$Res>
    implements _$LedgerEntryCopyWith<$Res> {
  __$LedgerEntryCopyWithImpl(this._self, this._then);

  final _LedgerEntry _self;
  final $Res Function(_LedgerEntry) _then;

/// Create a copy of LedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? xpDelta = null,Object? coinsDelta = null,Object? createdAt = null,}) {
  return _then(_LedgerEntry(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RewardReason,xpDelta: null == xpDelta ? _self.xpDelta : xpDelta // ignore: cast_nullable_to_non_nullable
as int,coinsDelta: null == coinsDelta ? _self.coinsDelta : coinsDelta // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
