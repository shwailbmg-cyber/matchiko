// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get name; String get handle; int get xp; int get coins; bool get verified; List<Position> get positions; int get reliability; int get played; int get wins; int get goals; bool get isReferee;/// Photo path in the avatars bucket (null → initials).
 String? get avatar;/// `cities.id` of the player's wilaya.
 String? get wilayaId; Level? get level;/// E.164 (+2135…); private, see `get_my_profile`.
 String? get phone;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.xp, _this.xp) || other.xp == _this.xp)&&(identical(other.coins, _this.coins) || other.coins == _this.coins)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&const DeepCollectionEquality().equals(other.positions, _this.positions)&&(identical(other.reliability, _this.reliability) || other.reliability == _this.reliability)&&(identical(other.played, _this.played) || other.played == _this.played)&&(identical(other.wins, _this.wins) || other.wins == _this.wins)&&(identical(other.goals, _this.goals) || other.goals == _this.goals)&&(identical(other.isReferee, _this.isReferee) || other.isReferee == _this.isReferee)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.wilayaId, _this.wilayaId) || other.wilayaId == _this.wilayaId)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.name,_this.handle,_this.xp,_this.coins,_this.verified,const DeepCollectionEquality().hash(_this.positions),_this.reliability,_this.played,_this.wins,_this.goals,_this.isReferee,_this.avatar,_this.wilayaId,_this.level,_this.phone);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(name: ${_this.name}, handle: ${_this.handle}, xp: ${_this.xp}, coins: ${_this.coins}, verified: ${_this.verified}, positions: ${_this.positions}, reliability: ${_this.reliability}, played: ${_this.played}, wins: ${_this.wins}, goals: ${_this.goals}, isReferee: ${_this.isReferee}, avatar: ${_this.avatar}, wilayaId: ${_this.wilayaId}, level: ${_this.level}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String name, String handle, int xp, int coins, bool verified, List<Position> positions, int reliability, int played, int wins, int goals, bool isReferee, String? avatar, String? wilayaId, Level? level, String? phone
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? handle = null,Object? xp = null,Object? coins = null,Object? verified = null,Object? positions = null,Object? reliability = null,Object? played = null,Object? wins = null,Object? goals = null,Object? isReferee = null,Object? avatar = freezed,Object? wilayaId = freezed,Object? level = freezed,Object? phone = freezed,}) {
  return _then(Profile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,reliability: null == reliability ? _self.reliability : reliability // ignore: cast_nullable_to_non_nullable
as int,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,isReferee: null == isReferee ? _self.isReferee : isReferee // ignore: cast_nullable_to_non_nullable
as bool,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,wilayaId: freezed == wilayaId ? _self.wilayaId : wilayaId // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String handle,  int xp,  int coins,  bool verified,  List<Position> positions,  int reliability,  int played,  int wins,  int goals,  bool isReferee,  String? avatar,  String? wilayaId,  Level? level,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.name,_that.handle,_that.xp,_that.coins,_that.verified,_that.positions,_that.reliability,_that.played,_that.wins,_that.goals,_that.isReferee,_that.avatar,_that.wilayaId,_that.level,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String handle,  int xp,  int coins,  bool verified,  List<Position> positions,  int reliability,  int played,  int wins,  int goals,  bool isReferee,  String? avatar,  String? wilayaId,  Level? level,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.name,_that.handle,_that.xp,_that.coins,_that.verified,_that.positions,_that.reliability,_that.played,_that.wins,_that.goals,_that.isReferee,_that.avatar,_that.wilayaId,_that.level,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String handle,  int xp,  int coins,  bool verified,  List<Position> positions,  int reliability,  int played,  int wins,  int goals,  bool isReferee,  String? avatar,  String? wilayaId,  Level? level,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.name,_that.handle,_that.xp,_that.coins,_that.verified,_that.positions,_that.reliability,_that.played,_that.wins,_that.goals,_that.isReferee,_that.avatar,_that.wilayaId,_that.level,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile extends Profile {
  const _Profile({required this.name, required this.handle, required this.xp, required this.coins, required this.verified, required  List<Position> positions, required this.reliability, required this.played, required this.wins, required this.goals, this.isReferee = false, this.avatar, this.wilayaId, this.level, this.phone}): _positions = positions,super._();
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String name;
@override final  String handle;
@override final  int xp;
@override final  int coins;
@override final  bool verified;
 final  List<Position> _positions;
@override List<Position> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}

@override final  int reliability;
@override final  int played;
@override final  int wins;
@override final  int goals;
@override@JsonKey() final  bool isReferee;
/// Photo path in the avatars bucket (null → initials).
@override final  String? avatar;
/// `cities.id` of the player's wilaya.
@override final  String? wilayaId;
@override final  Level? level;
/// E.164 (+2135…); private, see `get_my_profile`.
@override final  String? phone;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.verified, verified) || other.verified == verified)&&const DeepCollectionEquality().equals(other.positions, _positions)&&(identical(other.reliability, reliability) || other.reliability == reliability)&&(identical(other.played, played) || other.played == played)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.isReferee, isReferee) || other.isReferee == isReferee)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.wilayaId, wilayaId) || other.wilayaId == wilayaId)&&(identical(other.level, level) || other.level == level)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,handle,xp,coins,verified,const DeepCollectionEquality().hash(_positions),reliability,played,wins,goals,isReferee,avatar,wilayaId,level,phone);
}

@override
String toString() {
    return 'Profile(name: $name, handle: $handle, xp: $xp, coins: $coins, verified: $verified, positions: $positions, reliability: $reliability, played: $played, wins: $wins, goals: $goals, isReferee: $isReferee, avatar: $avatar, wilayaId: $wilayaId, level: $level, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String name, String handle, int xp, int coins, bool verified, List<Position> positions, int reliability, int played, int wins, int goals, bool isReferee, String? avatar, String? wilayaId, Level? level, String? phone
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? handle = null,Object? xp = null,Object? coins = null,Object? verified = null,Object? positions = null,Object? reliability = null,Object? played = null,Object? wins = null,Object? goals = null,Object? isReferee = null,Object? avatar = freezed,Object? wilayaId = freezed,Object? level = freezed,Object? phone = freezed,}) {
  return _then(_Profile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<Position>,reliability: null == reliability ? _self.reliability : reliability // ignore: cast_nullable_to_non_nullable
as int,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,isReferee: null == isReferee ? _self.isReferee : isReferee // ignore: cast_nullable_to_non_nullable
as bool,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,wilayaId: freezed == wilayaId ? _self.wilayaId : wilayaId // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
