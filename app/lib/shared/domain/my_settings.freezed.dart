// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MySettings {

 bool get notifyNearby; bool get notifyReminders; GamesVisibility get visibility;
/// Create a copy of MySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySettingsCopyWith<MySettings> get copyWith => _$MySettingsCopyWithImpl<MySettings>(this as MySettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MySettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySettings&&(identical(other.notifyNearby, _this.notifyNearby) || other.notifyNearby == _this.notifyNearby)&&(identical(other.notifyReminders, _this.notifyReminders) || other.notifyReminders == _this.notifyReminders)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility));
}


@override
int get hashCode {
  final _this = this as MySettings;
  return Object.hash(runtimeType,_this.notifyNearby,_this.notifyReminders,_this.visibility);
}

@override
String toString() {
  final _this = this as MySettings;
  return 'MySettings(notifyNearby: ${_this.notifyNearby}, notifyReminders: ${_this.notifyReminders}, visibility: ${_this.visibility})';
}


}

/// @nodoc
abstract mixin class $MySettingsCopyWith<$Res>  {
  factory $MySettingsCopyWith(MySettings value, $Res Function(MySettings) _then) = _$MySettingsCopyWithImpl;
@useResult
$Res call({
 bool notifyNearby, bool notifyReminders, GamesVisibility visibility
});




}
/// @nodoc
class _$MySettingsCopyWithImpl<$Res>
    implements $MySettingsCopyWith<$Res> {
  _$MySettingsCopyWithImpl(this._self, this._then);

  final MySettings _self;
  final $Res Function(MySettings) _then;

/// Create a copy of MySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notifyNearby = null,Object? notifyReminders = null,Object? visibility = null,}) {
  return _then(MySettings(
notifyNearby: null == notifyNearby ? _self.notifyNearby : notifyNearby // ignore: cast_nullable_to_non_nullable
as bool,notifyReminders: null == notifyReminders ? _self.notifyReminders : notifyReminders // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as GamesVisibility,
  ));
}

}


/// Adds pattern-matching-related methods to [MySettings].
extension MySettingsPatterns on MySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySettings value)  $default,){
final _that = this;
switch (_that) {
case _MySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySettings value)?  $default,){
final _that = this;
switch (_that) {
case _MySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool notifyNearby,  bool notifyReminders,  GamesVisibility visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySettings() when $default != null:
return $default(_that.notifyNearby,_that.notifyReminders,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool notifyNearby,  bool notifyReminders,  GamesVisibility visibility)  $default,) {final _that = this;
switch (_that) {
case _MySettings():
return $default(_that.notifyNearby,_that.notifyReminders,_that.visibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool notifyNearby,  bool notifyReminders,  GamesVisibility visibility)?  $default,) {final _that = this;
switch (_that) {
case _MySettings() when $default != null:
return $default(_that.notifyNearby,_that.notifyReminders,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc


class _MySettings implements MySettings {
  const _MySettings({this.notifyNearby = true, this.notifyReminders = true, this.visibility = GamesVisibility.friends});
  

@override@JsonKey() final  bool notifyNearby;
@override@JsonKey() final  bool notifyReminders;
@override@JsonKey() final  GamesVisibility visibility;

/// Create a copy of MySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySettingsCopyWith<_MySettings> get copyWith => __$MySettingsCopyWithImpl<_MySettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySettings&&(identical(other.notifyNearby, notifyNearby) || other.notifyNearby == notifyNearby)&&(identical(other.notifyReminders, notifyReminders) || other.notifyReminders == notifyReminders)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}


@override
int get hashCode {
    return Object.hash(runtimeType,notifyNearby,notifyReminders,visibility);
}

@override
String toString() {
    return 'MySettings(notifyNearby: $notifyNearby, notifyReminders: $notifyReminders, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$MySettingsCopyWith<$Res> implements $MySettingsCopyWith<$Res> {
  factory _$MySettingsCopyWith(_MySettings value, $Res Function(_MySettings) _then) = __$MySettingsCopyWithImpl;
@override @useResult
$Res call({
 bool notifyNearby, bool notifyReminders, GamesVisibility visibility
});




}
/// @nodoc
class __$MySettingsCopyWithImpl<$Res>
    implements _$MySettingsCopyWith<$Res> {
  __$MySettingsCopyWithImpl(this._self, this._then);

  final _MySettings _self;
  final $Res Function(_MySettings) _then;

/// Create a copy of MySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notifyNearby = null,Object? notifyReminders = null,Object? visibility = null,}) {
  return _then(_MySettings(
notifyNearby: null == notifyNearby ? _self.notifyNearby : notifyNearby // ignore: cast_nullable_to_non_nullable
as bool,notifyReminders: null == notifyReminders ? _self.notifyReminders : notifyReminders // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as GamesVisibility,
  ));
}


}

// dart format on
