// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Team {

 String get id; String get name; int get perSide; String get captainHandle; List<Player> get members; bool get iAmCaptain;/// ISO weekday, 1 = Monday.
 int? get usualWeekday; int? get usualHour; String? get usualPitchId; int get wins; int get draws; int get losses;
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamCopyWith<Team> get copyWith => _$TeamCopyWithImpl<Team>(this as Team, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Team;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Team&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.perSide, _this.perSide) || other.perSide == _this.perSide)&&(identical(other.captainHandle, _this.captainHandle) || other.captainHandle == _this.captainHandle)&&const DeepCollectionEquality().equals(other.members, _this.members)&&(identical(other.iAmCaptain, _this.iAmCaptain) || other.iAmCaptain == _this.iAmCaptain)&&(identical(other.usualWeekday, _this.usualWeekday) || other.usualWeekday == _this.usualWeekday)&&(identical(other.usualHour, _this.usualHour) || other.usualHour == _this.usualHour)&&(identical(other.usualPitchId, _this.usualPitchId) || other.usualPitchId == _this.usualPitchId)&&(identical(other.wins, _this.wins) || other.wins == _this.wins)&&(identical(other.draws, _this.draws) || other.draws == _this.draws)&&(identical(other.losses, _this.losses) || other.losses == _this.losses));
}


@override
int get hashCode {
  final _this = this as Team;
  return Object.hash(runtimeType,_this.id,_this.name,_this.perSide,_this.captainHandle,const DeepCollectionEquality().hash(_this.members),_this.iAmCaptain,_this.usualWeekday,_this.usualHour,_this.usualPitchId,_this.wins,_this.draws,_this.losses);
}

@override
String toString() {
  final _this = this as Team;
  return 'Team(id: ${_this.id}, name: ${_this.name}, perSide: ${_this.perSide}, captainHandle: ${_this.captainHandle}, members: ${_this.members}, iAmCaptain: ${_this.iAmCaptain}, usualWeekday: ${_this.usualWeekday}, usualHour: ${_this.usualHour}, usualPitchId: ${_this.usualPitchId}, wins: ${_this.wins}, draws: ${_this.draws}, losses: ${_this.losses})';
}


}

/// @nodoc
abstract mixin class $TeamCopyWith<$Res>  {
  factory $TeamCopyWith(Team value, $Res Function(Team) _then) = _$TeamCopyWithImpl;
@useResult
$Res call({
 String id, String name, int perSide, String captainHandle, List<Player> members, bool iAmCaptain, int? usualWeekday, int? usualHour, String? usualPitchId, int wins, int draws, int losses
});




}
/// @nodoc
class _$TeamCopyWithImpl<$Res>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._self, this._then);

  final Team _self;
  final $Res Function(Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? perSide = null,Object? captainHandle = null,Object? members = null,Object? iAmCaptain = null,Object? usualWeekday = freezed,Object? usualHour = freezed,Object? usualPitchId = freezed,Object? wins = null,Object? draws = null,Object? losses = null,}) {
  return _then(Team(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,captainHandle: null == captainHandle ? _self.captainHandle : captainHandle // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<Player>,iAmCaptain: null == iAmCaptain ? _self.iAmCaptain : iAmCaptain // ignore: cast_nullable_to_non_nullable
as bool,usualWeekday: freezed == usualWeekday ? _self.usualWeekday : usualWeekday // ignore: cast_nullable_to_non_nullable
as int?,usualHour: freezed == usualHour ? _self.usualHour : usualHour // ignore: cast_nullable_to_non_nullable
as int?,usualPitchId: freezed == usualPitchId ? _self.usualPitchId : usualPitchId // ignore: cast_nullable_to_non_nullable
as String?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Team].
extension TeamPatterns on Team {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Team value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Team value)  $default,){
final _that = this;
switch (_that) {
case _Team():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Team value)?  $default,){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int perSide,  String captainHandle,  List<Player> members,  bool iAmCaptain,  int? usualWeekday,  int? usualHour,  String? usualPitchId,  int wins,  int draws,  int losses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.perSide,_that.captainHandle,_that.members,_that.iAmCaptain,_that.usualWeekday,_that.usualHour,_that.usualPitchId,_that.wins,_that.draws,_that.losses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int perSide,  String captainHandle,  List<Player> members,  bool iAmCaptain,  int? usualWeekday,  int? usualHour,  String? usualPitchId,  int wins,  int draws,  int losses)  $default,) {final _that = this;
switch (_that) {
case _Team():
return $default(_that.id,_that.name,_that.perSide,_that.captainHandle,_that.members,_that.iAmCaptain,_that.usualWeekday,_that.usualHour,_that.usualPitchId,_that.wins,_that.draws,_that.losses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int perSide,  String captainHandle,  List<Player> members,  bool iAmCaptain,  int? usualWeekday,  int? usualHour,  String? usualPitchId,  int wins,  int draws,  int losses)?  $default,) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.perSide,_that.captainHandle,_that.members,_that.iAmCaptain,_that.usualWeekday,_that.usualHour,_that.usualPitchId,_that.wins,_that.draws,_that.losses);case _:
  return null;

}
}

}

/// @nodoc


class _Team extends Team {
  const _Team({required this.id, required this.name, required this.perSide, required this.captainHandle,  List<Player> members = const <Player>[], this.iAmCaptain = false, this.usualWeekday, this.usualHour, this.usualPitchId, this.wins = 0, this.draws = 0, this.losses = 0}): _members = members,super._();
  

@override final  String id;
@override final  String name;
@override final  int perSide;
@override final  String captainHandle;
 final  List<Player> _members;
@override@JsonKey() List<Player> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  bool iAmCaptain;
/// ISO weekday, 1 = Monday.
@override final  int? usualWeekday;
@override final  int? usualHour;
@override final  String? usualPitchId;
@override@JsonKey() final  int wins;
@override@JsonKey() final  int draws;
@override@JsonKey() final  int losses;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamCopyWith<_Team> get copyWith => __$TeamCopyWithImpl<_Team>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Team&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.perSide, perSide) || other.perSide == perSide)&&(identical(other.captainHandle, captainHandle) || other.captainHandle == captainHandle)&&const DeepCollectionEquality().equals(other.members, _members)&&(identical(other.iAmCaptain, iAmCaptain) || other.iAmCaptain == iAmCaptain)&&(identical(other.usualWeekday, usualWeekday) || other.usualWeekday == usualWeekday)&&(identical(other.usualHour, usualHour) || other.usualHour == usualHour)&&(identical(other.usualPitchId, usualPitchId) || other.usualPitchId == usualPitchId)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.losses, losses) || other.losses == losses));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,perSide,captainHandle,const DeepCollectionEquality().hash(_members),iAmCaptain,usualWeekday,usualHour,usualPitchId,wins,draws,losses);
}

@override
String toString() {
    return 'Team(id: $id, name: $name, perSide: $perSide, captainHandle: $captainHandle, members: $members, iAmCaptain: $iAmCaptain, usualWeekday: $usualWeekday, usualHour: $usualHour, usualPitchId: $usualPitchId, wins: $wins, draws: $draws, losses: $losses)';
}


}

/// @nodoc
abstract mixin class _$TeamCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$TeamCopyWith(_Team value, $Res Function(_Team) _then) = __$TeamCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int perSide, String captainHandle, List<Player> members, bool iAmCaptain, int? usualWeekday, int? usualHour, String? usualPitchId, int wins, int draws, int losses
});




}
/// @nodoc
class __$TeamCopyWithImpl<$Res>
    implements _$TeamCopyWith<$Res> {
  __$TeamCopyWithImpl(this._self, this._then);

  final _Team _self;
  final $Res Function(_Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? perSide = null,Object? captainHandle = null,Object? members = null,Object? iAmCaptain = null,Object? usualWeekday = freezed,Object? usualHour = freezed,Object? usualPitchId = freezed,Object? wins = null,Object? draws = null,Object? losses = null,}) {
  return _then(_Team(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,captainHandle: null == captainHandle ? _self.captainHandle : captainHandle // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<Player>,iAmCaptain: null == iAmCaptain ? _self.iAmCaptain : iAmCaptain // ignore: cast_nullable_to_non_nullable
as bool,usualWeekday: freezed == usualWeekday ? _self.usualWeekday : usualWeekday // ignore: cast_nullable_to_non_nullable
as int?,usualHour: freezed == usualHour ? _self.usualHour : usualHour // ignore: cast_nullable_to_non_nullable
as int?,usualPitchId: freezed == usualPitchId ? _self.usualPitchId : usualPitchId // ignore: cast_nullable_to_non_nullable
as String?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
