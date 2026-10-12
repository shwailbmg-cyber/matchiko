// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Player {

 String get handle; String get name; String? get wilayaId; List<Position> get positions; int get xp; bool get verified; int get played; FriendStatus get friend;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Player;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.wilayaId, _this.wilayaId) || other.wilayaId == _this.wilayaId)&&const DeepCollectionEquality().equals(other.positions, _this.positions)&&(identical(other.xp, _this.xp) || other.xp == _this.xp)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.played, _this.played) || other.played == _this.played)&&(identical(other.friend, _this.friend) || other.friend == _this.friend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Player;
  return Object.hash(runtimeType,_this.handle,_this.name,_this.wilayaId,const DeepCollectionEquality().hash(_this.positions),_this.xp,_this.verified,_this.played,_this.friend);
}

@override
String toString() {
  final _this = this as Player;
  return 'Player(handle: ${_this.handle}, name: ${_this.name}, wilayaId: ${_this.wilayaId}, positions: ${_this.positions}, xp: ${_this.xp}, verified: ${_this.verified}, played: ${_this.played}, friend: ${_this.friend})';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String handle, String name, String? wilayaId, List<Position> positions, int xp, bool verified, int played, FriendStatus friend
});




}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handle = null,Object? name = null,Object? wilayaId = freezed,Object? positions = null,Object? xp = null,Object? verified = null,Object? played = null,Object? friend = null,}) {
  return _then(Player(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,wilayaId: freezed == wilayaId ? _self.wilayaId : wilayaId // ignore: cast_nullable_to_non_nullable
as String?,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as int,friend: null == friend ? _self.friend : friend // ignore: cast_nullable_to_non_nullable
as FriendStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String handle,  String name,  String? wilayaId,  List<Position> positions,  int xp,  bool verified,  int played,  FriendStatus friend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.handle,_that.name,_that.wilayaId,_that.positions,_that.xp,_that.verified,_that.played,_that.friend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String handle,  String name,  String? wilayaId,  List<Position> positions,  int xp,  bool verified,  int played,  FriendStatus friend)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.handle,_that.name,_that.wilayaId,_that.positions,_that.xp,_that.verified,_that.played,_that.friend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String handle,  String name,  String? wilayaId,  List<Position> positions,  int xp,  bool verified,  int played,  FriendStatus friend)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.handle,_that.name,_that.wilayaId,_that.positions,_that.xp,_that.verified,_that.played,_that.friend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player extends Player {
  const _Player({required this.handle, required this.name, this.wilayaId,  List<Position> positions = const <Position>[], this.xp = 0, this.verified = false, this.played = 0, this.friend = FriendStatus.none}): _positions = positions,super._();
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  String handle;
@override final  String name;
@override final  String? wilayaId;
 final  List<Position> _positions;
@override@JsonKey() List<Position> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}

@override@JsonKey() final  int xp;
@override@JsonKey() final  bool verified;
@override@JsonKey() final  int played;
@override@JsonKey() final  FriendStatus friend;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.wilayaId, wilayaId) || other.wilayaId == wilayaId)&&const DeepCollectionEquality().equals(other.positions, _positions)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.played, played) || other.played == played)&&(identical(other.friend, friend) || other.friend == friend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,handle,name,wilayaId,const DeepCollectionEquality().hash(_positions),xp,verified,played,friend);
}

@override
String toString() {
    return 'Player(handle: $handle, name: $name, wilayaId: $wilayaId, positions: $positions, xp: $xp, verified: $verified, played: $played, friend: $friend)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String handle, String name, String? wilayaId, List<Position> positions, int xp, bool verified, int played, FriendStatus friend
});




}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handle = null,Object? name = null,Object? wilayaId = freezed,Object? positions = null,Object? xp = null,Object? verified = null,Object? played = null,Object? friend = null,}) {
  return _then(_Player(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,wilayaId: freezed == wilayaId ? _self.wilayaId : wilayaId // ignore: cast_nullable_to_non_nullable
as String?,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as int,friend: null == friend ? _self.friend : friend // ignore: cast_nullable_to_non_nullable
as FriendStatus,
  ));
}


}

// dart format on
