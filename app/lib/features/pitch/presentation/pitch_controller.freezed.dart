// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pitch_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingDraft {

 int get dayIndex; Slot? get selected;/// Players per side; 0 means the pitch's maximum.
 int get perSide; bool get withReferee; bool get sending;
/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingDraftCopyWith<BookingDraft> get copyWith => _$BookingDraftCopyWithImpl<BookingDraft>(this as BookingDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BookingDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingDraft&&(identical(other.dayIndex, _this.dayIndex) || other.dayIndex == _this.dayIndex)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.perSide, _this.perSide) || other.perSide == _this.perSide)&&(identical(other.withReferee, _this.withReferee) || other.withReferee == _this.withReferee)&&(identical(other.sending, _this.sending) || other.sending == _this.sending));
}


@override
int get hashCode {
  final _this = this as BookingDraft;
  return Object.hash(runtimeType,_this.dayIndex,_this.selected,_this.perSide,_this.withReferee,_this.sending);
}

@override
String toString() {
  final _this = this as BookingDraft;
  return 'BookingDraft(dayIndex: ${_this.dayIndex}, selected: ${_this.selected}, perSide: ${_this.perSide}, withReferee: ${_this.withReferee}, sending: ${_this.sending})';
}


}

/// @nodoc
abstract mixin class $BookingDraftCopyWith<$Res>  {
  factory $BookingDraftCopyWith(BookingDraft value, $Res Function(BookingDraft) _then) = _$BookingDraftCopyWithImpl;
@useResult
$Res call({
 int dayIndex, Slot? selected, int perSide, bool withReferee, bool sending
});


$SlotCopyWith<$Res>? get selected;

}
/// @nodoc
class _$BookingDraftCopyWithImpl<$Res>
    implements $BookingDraftCopyWith<$Res> {
  _$BookingDraftCopyWithImpl(this._self, this._then);

  final BookingDraft _self;
  final $Res Function(BookingDraft) _then;

/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayIndex = null,Object? selected = freezed,Object? perSide = null,Object? withReferee = null,Object? sending = null,}) {
  return _then(BookingDraft(
dayIndex: null == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Slot?,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,withReferee: null == withReferee ? _self.withReferee : withReferee // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $SlotCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingDraft].
extension BookingDraftPatterns on BookingDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingDraft value)  $default,){
final _that = this;
switch (_that) {
case _BookingDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _BookingDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dayIndex,  Slot? selected,  int perSide,  bool withReferee,  bool sending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingDraft() when $default != null:
return $default(_that.dayIndex,_that.selected,_that.perSide,_that.withReferee,_that.sending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dayIndex,  Slot? selected,  int perSide,  bool withReferee,  bool sending)  $default,) {final _that = this;
switch (_that) {
case _BookingDraft():
return $default(_that.dayIndex,_that.selected,_that.perSide,_that.withReferee,_that.sending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dayIndex,  Slot? selected,  int perSide,  bool withReferee,  bool sending)?  $default,) {final _that = this;
switch (_that) {
case _BookingDraft() when $default != null:
return $default(_that.dayIndex,_that.selected,_that.perSide,_that.withReferee,_that.sending);case _:
  return null;

}
}

}

/// @nodoc


class _BookingDraft implements BookingDraft {
  const _BookingDraft({this.dayIndex = 0, this.selected, this.perSide = 0, this.withReferee = false, this.sending = false});
  

@override@JsonKey() final  int dayIndex;
@override final  Slot? selected;
/// Players per side; 0 means the pitch's maximum.
@override@JsonKey() final  int perSide;
@override@JsonKey() final  bool withReferee;
@override@JsonKey() final  bool sending;

/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingDraftCopyWith<_BookingDraft> get copyWith => __$BookingDraftCopyWithImpl<_BookingDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingDraft&&(identical(other.dayIndex, dayIndex) || other.dayIndex == dayIndex)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.perSide, perSide) || other.perSide == perSide)&&(identical(other.withReferee, withReferee) || other.withReferee == withReferee)&&(identical(other.sending, sending) || other.sending == sending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dayIndex,selected,perSide,withReferee,sending);
}

@override
String toString() {
    return 'BookingDraft(dayIndex: $dayIndex, selected: $selected, perSide: $perSide, withReferee: $withReferee, sending: $sending)';
}


}

/// @nodoc
abstract mixin class _$BookingDraftCopyWith<$Res> implements $BookingDraftCopyWith<$Res> {
  factory _$BookingDraftCopyWith(_BookingDraft value, $Res Function(_BookingDraft) _then) = __$BookingDraftCopyWithImpl;
@override @useResult
$Res call({
 int dayIndex, Slot? selected, int perSide, bool withReferee, bool sending
});


@override $SlotCopyWith<$Res>? get selected;

}
/// @nodoc
class __$BookingDraftCopyWithImpl<$Res>
    implements _$BookingDraftCopyWith<$Res> {
  __$BookingDraftCopyWithImpl(this._self, this._then);

  final _BookingDraft _self;
  final $Res Function(_BookingDraft) _then;

/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayIndex = null,Object? selected = freezed,Object? perSide = null,Object? withReferee = null,Object? sending = null,}) {
  return _then(_BookingDraft(
dayIndex: null == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Slot?,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,withReferee: null == withReferee ? _self.withReferee : withReferee // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BookingDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $SlotCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}

// dart format on
