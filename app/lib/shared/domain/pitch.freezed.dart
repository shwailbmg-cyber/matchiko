// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pitch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pitch {

 String get id; String get venue; String get venueAr; String get district; double get km; double get rating; int get reviews;/// Largest game the pitch fits (players per side).
 int get maxPerSide; int get priceDa; Set<Feature> get features;
/// Create a copy of Pitch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PitchCopyWith<Pitch> get copyWith => _$PitchCopyWithImpl<Pitch>(this as Pitch, _$identity);

  /// Serializes this Pitch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Pitch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pitch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.venueAr, _this.venueAr) || other.venueAr == _this.venueAr)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.km, _this.km) || other.km == _this.km)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviews, _this.reviews) || other.reviews == _this.reviews)&&(identical(other.maxPerSide, _this.maxPerSide) || other.maxPerSide == _this.maxPerSide)&&(identical(other.priceDa, _this.priceDa) || other.priceDa == _this.priceDa)&&const DeepCollectionEquality().equals(other.features, _this.features));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Pitch;
  return Object.hash(runtimeType,_this.id,_this.venue,_this.venueAr,_this.district,_this.km,_this.rating,_this.reviews,_this.maxPerSide,_this.priceDa,const DeepCollectionEquality().hash(_this.features));
}

@override
String toString() {
  final _this = this as Pitch;
  return 'Pitch(id: ${_this.id}, venue: ${_this.venue}, venueAr: ${_this.venueAr}, district: ${_this.district}, km: ${_this.km}, rating: ${_this.rating}, reviews: ${_this.reviews}, maxPerSide: ${_this.maxPerSide}, priceDa: ${_this.priceDa}, features: ${_this.features})';
}


}

/// @nodoc
abstract mixin class $PitchCopyWith<$Res>  {
  factory $PitchCopyWith(Pitch value, $Res Function(Pitch) _then) = _$PitchCopyWithImpl;
@useResult
$Res call({
 String id, String venue, String venueAr, String district, double km, double rating, int reviews, int maxPerSide, int priceDa, Set<Feature> features
});




}
/// @nodoc
class _$PitchCopyWithImpl<$Res>
    implements $PitchCopyWith<$Res> {
  _$PitchCopyWithImpl(this._self, this._then);

  final Pitch _self;
  final $Res Function(Pitch) _then;

/// Create a copy of Pitch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? venue = null,Object? venueAr = null,Object? district = null,Object? km = null,Object? rating = null,Object? reviews = null,Object? maxPerSide = null,Object? priceDa = null,Object? features = null,}) {
  return _then(Pitch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,venueAr: null == venueAr ? _self.venueAr : venueAr // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as int,maxPerSide: null == maxPerSide ? _self.maxPerSide : maxPerSide // ignore: cast_nullable_to_non_nullable
as int,priceDa: null == priceDa ? _self.priceDa : priceDa // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,
  ));
}

}


/// Adds pattern-matching-related methods to [Pitch].
extension PitchPatterns on Pitch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pitch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pitch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pitch value)  $default,){
final _that = this;
switch (_that) {
case _Pitch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pitch value)?  $default,){
final _that = this;
switch (_that) {
case _Pitch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String venue,  String venueAr,  String district,  double km,  double rating,  int reviews,  int maxPerSide,  int priceDa,  Set<Feature> features)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pitch() when $default != null:
return $default(_that.id,_that.venue,_that.venueAr,_that.district,_that.km,_that.rating,_that.reviews,_that.maxPerSide,_that.priceDa,_that.features);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String venue,  String venueAr,  String district,  double km,  double rating,  int reviews,  int maxPerSide,  int priceDa,  Set<Feature> features)  $default,) {final _that = this;
switch (_that) {
case _Pitch():
return $default(_that.id,_that.venue,_that.venueAr,_that.district,_that.km,_that.rating,_that.reviews,_that.maxPerSide,_that.priceDa,_that.features);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String venue,  String venueAr,  String district,  double km,  double rating,  int reviews,  int maxPerSide,  int priceDa,  Set<Feature> features)?  $default,) {final _that = this;
switch (_that) {
case _Pitch() when $default != null:
return $default(_that.id,_that.venue,_that.venueAr,_that.district,_that.km,_that.rating,_that.reviews,_that.maxPerSide,_that.priceDa,_that.features);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pitch extends Pitch {
  const _Pitch({required this.id, required this.venue, required this.venueAr, required this.district, required this.km, required this.rating, required this.reviews, required this.maxPerSide, required this.priceDa, required  Set<Feature> features}): _features = features,super._();
  factory _Pitch.fromJson(Map<String, dynamic> json) => _$PitchFromJson(json);

@override final  String id;
@override final  String venue;
@override final  String venueAr;
@override final  String district;
@override final  double km;
@override final  double rating;
@override final  int reviews;
/// Largest game the pitch fits (players per side).
@override final  int maxPerSide;
@override final  int priceDa;
 final  Set<Feature> _features;
@override Set<Feature> get features {
  if (_features is EqualUnmodifiableSetView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_features);
}


/// Create a copy of Pitch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PitchCopyWith<_Pitch> get copyWith => __$PitchCopyWithImpl<_Pitch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PitchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pitch&&(identical(other.id, id) || other.id == id)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.venueAr, venueAr) || other.venueAr == venueAr)&&(identical(other.district, district) || other.district == district)&&(identical(other.km, km) || other.km == km)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviews, reviews) || other.reviews == reviews)&&(identical(other.maxPerSide, maxPerSide) || other.maxPerSide == maxPerSide)&&(identical(other.priceDa, priceDa) || other.priceDa == priceDa)&&const DeepCollectionEquality().equals(other.features, _features));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,venue,venueAr,district,km,rating,reviews,maxPerSide,priceDa,const DeepCollectionEquality().hash(_features));
}

@override
String toString() {
    return 'Pitch(id: $id, venue: $venue, venueAr: $venueAr, district: $district, km: $km, rating: $rating, reviews: $reviews, maxPerSide: $maxPerSide, priceDa: $priceDa, features: $features)';
}


}

/// @nodoc
abstract mixin class _$PitchCopyWith<$Res> implements $PitchCopyWith<$Res> {
  factory _$PitchCopyWith(_Pitch value, $Res Function(_Pitch) _then) = __$PitchCopyWithImpl;
@override @useResult
$Res call({
 String id, String venue, String venueAr, String district, double km, double rating, int reviews, int maxPerSide, int priceDa, Set<Feature> features
});




}
/// @nodoc
class __$PitchCopyWithImpl<$Res>
    implements _$PitchCopyWith<$Res> {
  __$PitchCopyWithImpl(this._self, this._then);

  final _Pitch _self;
  final $Res Function(_Pitch) _then;

/// Create a copy of Pitch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? venue = null,Object? venueAr = null,Object? district = null,Object? km = null,Object? rating = null,Object? reviews = null,Object? maxPerSide = null,Object? priceDa = null,Object? features = null,}) {
  return _then(_Pitch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,venueAr: null == venueAr ? _self.venueAr : venueAr // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,km: null == km ? _self.km : km // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as int,maxPerSide: null == maxPerSide ? _self.maxPerSide : maxPerSide // ignore: cast_nullable_to_non_nullable
as int,priceDa: null == priceDa ? _self.priceDa : priceDa // ignore: cast_nullable_to_non_nullable
as int,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,
  ));
}


}


/// @nodoc
mixin _$Slot {

 DateTime get startsAt; SlotState get state;
/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotCopyWith<Slot> get copyWith => _$SlotCopyWithImpl<Slot>(this as Slot, _$identity);

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Slot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Slot&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.state, _this.state) || other.state == _this.state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Slot;
  return Object.hash(runtimeType,_this.startsAt,_this.state);
}

@override
String toString() {
  final _this = this as Slot;
  return 'Slot(startsAt: ${_this.startsAt}, state: ${_this.state})';
}


}

/// @nodoc
abstract mixin class $SlotCopyWith<$Res>  {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) _then) = _$SlotCopyWithImpl;
@useResult
$Res call({
 DateTime startsAt, SlotState state
});




}
/// @nodoc
class _$SlotCopyWithImpl<$Res>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._self, this._then);

  final Slot _self;
  final $Res Function(Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startsAt = null,Object? state = null,}) {
  return _then(Slot(
null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SlotState,
  ));
}

}


/// Adds pattern-matching-related methods to [Slot].
extension SlotPatterns on Slot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Slot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Slot value)  $default,){
final _that = this;
switch (_that) {
case _Slot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Slot value)?  $default,){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startsAt,  SlotState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.startsAt,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startsAt,  SlotState state)  $default,) {final _that = this;
switch (_that) {
case _Slot():
return $default(_that.startsAt,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startsAt,  SlotState state)?  $default,) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.startsAt,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Slot implements Slot {
  const _Slot(this.startsAt, this.state);
  factory _Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

@override final  DateTime startsAt;
@override final  SlotState state;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlotCopyWith<_Slot> get copyWith => __$SlotCopyWithImpl<_Slot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Slot&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,startsAt,state);
}

@override
String toString() {
    return 'Slot(startsAt: $startsAt, state: $state)';
}


}

/// @nodoc
abstract mixin class _$SlotCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$SlotCopyWith(_Slot value, $Res Function(_Slot) _then) = __$SlotCopyWithImpl;
@override @useResult
$Res call({
 DateTime startsAt, SlotState state
});




}
/// @nodoc
class __$SlotCopyWithImpl<$Res>
    implements _$SlotCopyWith<$Res> {
  __$SlotCopyWithImpl(this._self, this._then);

  final _Slot _self;
  final $Res Function(_Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startsAt = null,Object? state = null,}) {
  return _then(_Slot(
null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SlotState,
  ));
}


}

// dart format on
