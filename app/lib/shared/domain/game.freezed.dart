// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GamePlayer {

 String get name; String get handle; Position get position; Team get team; int get reliability; bool get paid; bool get confirmed;/// Added by the booker, has no account.
 bool get guest; bool get isMe; bool get isBooker;
/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerCopyWith<GamePlayer> get copyWith => _$GamePlayerCopyWithImpl<GamePlayer>(this as GamePlayer, _$identity);

  /// Serializes this GamePlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GamePlayer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayer&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.handle, _this.handle) || other.handle == _this.handle)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.team, _this.team) || other.team == _this.team)&&(identical(other.reliability, _this.reliability) || other.reliability == _this.reliability)&&(identical(other.paid, _this.paid) || other.paid == _this.paid)&&(identical(other.confirmed, _this.confirmed) || other.confirmed == _this.confirmed)&&(identical(other.guest, _this.guest) || other.guest == _this.guest)&&(identical(other.isMe, _this.isMe) || other.isMe == _this.isMe)&&(identical(other.isBooker, _this.isBooker) || other.isBooker == _this.isBooker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GamePlayer;
  return Object.hash(runtimeType,_this.name,_this.handle,_this.position,_this.team,_this.reliability,_this.paid,_this.confirmed,_this.guest,_this.isMe,_this.isBooker);
}

@override
String toString() {
  final _this = this as GamePlayer;
  return 'GamePlayer(name: ${_this.name}, handle: ${_this.handle}, position: ${_this.position}, team: ${_this.team}, reliability: ${_this.reliability}, paid: ${_this.paid}, confirmed: ${_this.confirmed}, guest: ${_this.guest}, isMe: ${_this.isMe}, isBooker: ${_this.isBooker})';
}


}

/// @nodoc
abstract mixin class $GamePlayerCopyWith<$Res>  {
  factory $GamePlayerCopyWith(GamePlayer value, $Res Function(GamePlayer) _then) = _$GamePlayerCopyWithImpl;
@useResult
$Res call({
 String name, String handle, Position position, Team team, int reliability, bool paid, bool confirmed, bool guest, bool isMe, bool isBooker
});




}
/// @nodoc
class _$GamePlayerCopyWithImpl<$Res>
    implements $GamePlayerCopyWith<$Res> {
  _$GamePlayerCopyWithImpl(this._self, this._then);

  final GamePlayer _self;
  final $Res Function(GamePlayer) _then;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? handle = null,Object? position = null,Object? team = null,Object? reliability = null,Object? paid = null,Object? confirmed = null,Object? guest = null,Object? isMe = null,Object? isBooker = null,}) {
  return _then(GamePlayer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team,reliability: null == reliability ? _self.reliability : reliability // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,guest: null == guest ? _self.guest : guest // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isBooker: null == isBooker ? _self.isBooker : isBooker // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GamePlayer].
extension GamePlayerPatterns on GamePlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePlayer value)  $default,){
final _that = this;
switch (_that) {
case _GamePlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePlayer value)?  $default,){
final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String handle,  Position position,  Team team,  int reliability,  bool paid,  bool confirmed,  bool guest,  bool isMe,  bool isBooker)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that.name,_that.handle,_that.position,_that.team,_that.reliability,_that.paid,_that.confirmed,_that.guest,_that.isMe,_that.isBooker);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String handle,  Position position,  Team team,  int reliability,  bool paid,  bool confirmed,  bool guest,  bool isMe,  bool isBooker)  $default,) {final _that = this;
switch (_that) {
case _GamePlayer():
return $default(_that.name,_that.handle,_that.position,_that.team,_that.reliability,_that.paid,_that.confirmed,_that.guest,_that.isMe,_that.isBooker);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String handle,  Position position,  Team team,  int reliability,  bool paid,  bool confirmed,  bool guest,  bool isMe,  bool isBooker)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that.name,_that.handle,_that.position,_that.team,_that.reliability,_that.paid,_that.confirmed,_that.guest,_that.isMe,_that.isBooker);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamePlayer extends GamePlayer {
  const _GamePlayer({required this.name, required this.handle, required this.position, required this.team, this.reliability = 100, this.paid = false, this.confirmed = true, this.guest = false, this.isMe = false, this.isBooker = false}): super._();
  factory _GamePlayer.fromJson(Map<String, dynamic> json) => _$GamePlayerFromJson(json);

@override final  String name;
@override final  String handle;
@override final  Position position;
@override final  Team team;
@override@JsonKey() final  int reliability;
@override@JsonKey() final  bool paid;
@override@JsonKey() final  bool confirmed;
/// Added by the booker, has no account.
@override@JsonKey() final  bool guest;
@override@JsonKey() final  bool isMe;
@override@JsonKey() final  bool isBooker;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlayerCopyWith<_GamePlayer> get copyWith => __$GamePlayerCopyWithImpl<_GamePlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamePlayerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayer&&(identical(other.name, name) || other.name == name)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.position, position) || other.position == position)&&(identical(other.team, team) || other.team == team)&&(identical(other.reliability, reliability) || other.reliability == reliability)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.guest, guest) || other.guest == guest)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isBooker, isBooker) || other.isBooker == isBooker));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,handle,position,team,reliability,paid,confirmed,guest,isMe,isBooker);
}

@override
String toString() {
    return 'GamePlayer(name: $name, handle: $handle, position: $position, team: $team, reliability: $reliability, paid: $paid, confirmed: $confirmed, guest: $guest, isMe: $isMe, isBooker: $isBooker)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerCopyWith<$Res> implements $GamePlayerCopyWith<$Res> {
  factory _$GamePlayerCopyWith(_GamePlayer value, $Res Function(_GamePlayer) _then) = __$GamePlayerCopyWithImpl;
@override @useResult
$Res call({
 String name, String handle, Position position, Team team, int reliability, bool paid, bool confirmed, bool guest, bool isMe, bool isBooker
});




}
/// @nodoc
class __$GamePlayerCopyWithImpl<$Res>
    implements _$GamePlayerCopyWith<$Res> {
  __$GamePlayerCopyWithImpl(this._self, this._then);

  final _GamePlayer _self;
  final $Res Function(_GamePlayer) _then;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? handle = null,Object? position = null,Object? team = null,Object? reliability = null,Object? paid = null,Object? confirmed = null,Object? guest = null,Object? isMe = null,Object? isBooker = null,}) {
  return _then(_GamePlayer(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as Team,reliability: null == reliability ? _self.reliability : reliability // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as bool,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,guest: null == guest ? _self.guest : guest // ignore: cast_nullable_to_non_nullable
as bool,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isBooker: null == isBooker ? _self.isBooker : isBooker // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Game {

 String get id; Pitch get pitch; DateTime get startsAt; int get perSide; BookingStatus get status; List<GamePlayer> get players;/// Free spots shown to other players.
 bool get open; int get waitlist; bool get competitive;/// Booking code shown under the QR.
 String get code;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Game;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.pitch, _this.pitch) || other.pitch == _this.pitch)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.perSide, _this.perSide) || other.perSide == _this.perSide)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.players, _this.players)&&(identical(other.open, _this.open) || other.open == _this.open)&&(identical(other.waitlist, _this.waitlist) || other.waitlist == _this.waitlist)&&(identical(other.competitive, _this.competitive) || other.competitive == _this.competitive)&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Game;
  return Object.hash(runtimeType,_this.id,_this.pitch,_this.startsAt,_this.perSide,_this.status,const DeepCollectionEquality().hash(_this.players),_this.open,_this.waitlist,_this.competitive,_this.code);
}

@override
String toString() {
  final _this = this as Game;
  return 'Game(id: ${_this.id}, pitch: ${_this.pitch}, startsAt: ${_this.startsAt}, perSide: ${_this.perSide}, status: ${_this.status}, players: ${_this.players}, open: ${_this.open}, waitlist: ${_this.waitlist}, competitive: ${_this.competitive}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String id, Pitch pitch, DateTime startsAt, int perSide, BookingStatus status, List<GamePlayer> players, bool open, int waitlist, bool competitive, String code
});


$PitchCopyWith<$Res> get pitch;

}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pitch = null,Object? startsAt = null,Object? perSide = null,Object? status = null,Object? players = null,Object? open = null,Object? waitlist = null,Object? competitive = null,Object? code = null,}) {
  return _then(Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as Pitch,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayer>,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool,waitlist: null == waitlist ? _self.waitlist : waitlist // ignore: cast_nullable_to_non_nullable
as int,competitive: null == competitive ? _self.competitive : competitive // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PitchCopyWith<$Res> get pitch {
  
  return $PitchCopyWith<$Res>(_self.pitch, (value) {
    return _then(_self.copyWith(pitch: value));
  });
}
}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Pitch pitch,  DateTime startsAt,  int perSide,  BookingStatus status,  List<GamePlayer> players,  bool open,  int waitlist,  bool competitive,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.pitch,_that.startsAt,_that.perSide,_that.status,_that.players,_that.open,_that.waitlist,_that.competitive,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Pitch pitch,  DateTime startsAt,  int perSide,  BookingStatus status,  List<GamePlayer> players,  bool open,  int waitlist,  bool competitive,  String code)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.id,_that.pitch,_that.startsAt,_that.perSide,_that.status,_that.players,_that.open,_that.waitlist,_that.competitive,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Pitch pitch,  DateTime startsAt,  int perSide,  BookingStatus status,  List<GamePlayer> players,  bool open,  int waitlist,  bool competitive,  String code)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.pitch,_that.startsAt,_that.perSide,_that.status,_that.players,_that.open,_that.waitlist,_that.competitive,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game extends Game {
  const _Game({required this.id, required this.pitch, required this.startsAt, required this.perSide, required this.status, required  List<GamePlayer> players, this.open = false, this.waitlist = 0, this.competitive = false, this.code = ''}): _players = players,super._();
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override final  String id;
@override final  Pitch pitch;
@override final  DateTime startsAt;
@override final  int perSide;
@override final  BookingStatus status;
 final  List<GamePlayer> _players;
@override List<GamePlayer> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

/// Free spots shown to other players.
@override@JsonKey() final  bool open;
@override@JsonKey() final  int waitlist;
@override@JsonKey() final  bool competitive;
/// Booking code shown under the QR.
@override@JsonKey() final  String code;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.id, id) || other.id == id)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.perSide, perSide) || other.perSide == perSide)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.players, _players)&&(identical(other.open, open) || other.open == open)&&(identical(other.waitlist, waitlist) || other.waitlist == waitlist)&&(identical(other.competitive, competitive) || other.competitive == competitive)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,pitch,startsAt,perSide,status,const DeepCollectionEquality().hash(_players),open,waitlist,competitive,code);
}

@override
String toString() {
    return 'Game(id: $id, pitch: $pitch, startsAt: $startsAt, perSide: $perSide, status: $status, players: $players, open: $open, waitlist: $waitlist, competitive: $competitive, code: $code)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String id, Pitch pitch, DateTime startsAt, int perSide, BookingStatus status, List<GamePlayer> players, bool open, int waitlist, bool competitive, String code
});


@override $PitchCopyWith<$Res> get pitch;

}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pitch = null,Object? startsAt = null,Object? perSide = null,Object? status = null,Object? players = null,Object? open = null,Object? waitlist = null,Object? competitive = null,Object? code = null,}) {
  return _then(_Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as Pitch,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,perSide: null == perSide ? _self.perSide : perSide // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayer>,open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool,waitlist: null == waitlist ? _self.waitlist : waitlist // ignore: cast_nullable_to_non_nullable
as int,competitive: null == competitive ? _self.competitive : competitive // ignore: cast_nullable_to_non_nullable
as bool,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PitchCopyWith<$Res> get pitch {
  
  return $PitchCopyWith<$Res>(_self.pitch, (value) {
    return _then(_self.copyWith(pitch: value));
  });
}
}

// dart format on
