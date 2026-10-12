// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pitch_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PitchFilter {

/// Pitch must fit at least this many players per side (null = any).
 int? get minPerSide;/// Price per hour at most (null = any).
 int? get maxPriceDa; Set<Feature> get features; bool get favoritesOnly;
/// Create a copy of PitchFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PitchFilterCopyWith<PitchFilter> get copyWith => _$PitchFilterCopyWithImpl<PitchFilter>(this as PitchFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PitchFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PitchFilter&&(identical(other.minPerSide, _this.minPerSide) || other.minPerSide == _this.minPerSide)&&(identical(other.maxPriceDa, _this.maxPriceDa) || other.maxPriceDa == _this.maxPriceDa)&&const DeepCollectionEquality().equals(other.features, _this.features)&&(identical(other.favoritesOnly, _this.favoritesOnly) || other.favoritesOnly == _this.favoritesOnly));
}


@override
int get hashCode {
  final _this = this as PitchFilter;
  return Object.hash(runtimeType,_this.minPerSide,_this.maxPriceDa,const DeepCollectionEquality().hash(_this.features),_this.favoritesOnly);
}

@override
String toString() {
  final _this = this as PitchFilter;
  return 'PitchFilter(minPerSide: ${_this.minPerSide}, maxPriceDa: ${_this.maxPriceDa}, features: ${_this.features}, favoritesOnly: ${_this.favoritesOnly})';
}


}

/// @nodoc
abstract mixin class $PitchFilterCopyWith<$Res>  {
  factory $PitchFilterCopyWith(PitchFilter value, $Res Function(PitchFilter) _then) = _$PitchFilterCopyWithImpl;
@useResult
$Res call({
 int? minPerSide, int? maxPriceDa, Set<Feature> features, bool favoritesOnly
});




}
/// @nodoc
class _$PitchFilterCopyWithImpl<$Res>
    implements $PitchFilterCopyWith<$Res> {
  _$PitchFilterCopyWithImpl(this._self, this._then);

  final PitchFilter _self;
  final $Res Function(PitchFilter) _then;

/// Create a copy of PitchFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minPerSide = freezed,Object? maxPriceDa = freezed,Object? features = null,Object? favoritesOnly = null,}) {
  return _then(PitchFilter(
minPerSide: freezed == minPerSide ? _self.minPerSide : minPerSide // ignore: cast_nullable_to_non_nullable
as int?,maxPriceDa: freezed == maxPriceDa ? _self.maxPriceDa : maxPriceDa // ignore: cast_nullable_to_non_nullable
as int?,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PitchFilter].
extension PitchFilterPatterns on PitchFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PitchFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PitchFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PitchFilter value)  $default,){
final _that = this;
switch (_that) {
case _PitchFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PitchFilter value)?  $default,){
final _that = this;
switch (_that) {
case _PitchFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? minPerSide,  int? maxPriceDa,  Set<Feature> features,  bool favoritesOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PitchFilter() when $default != null:
return $default(_that.minPerSide,_that.maxPriceDa,_that.features,_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? minPerSide,  int? maxPriceDa,  Set<Feature> features,  bool favoritesOnly)  $default,) {final _that = this;
switch (_that) {
case _PitchFilter():
return $default(_that.minPerSide,_that.maxPriceDa,_that.features,_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? minPerSide,  int? maxPriceDa,  Set<Feature> features,  bool favoritesOnly)?  $default,) {final _that = this;
switch (_that) {
case _PitchFilter() when $default != null:
return $default(_that.minPerSide,_that.maxPriceDa,_that.features,_that.favoritesOnly);case _:
  return null;

}
}

}

/// @nodoc


class _PitchFilter extends PitchFilter {
  const _PitchFilter({this.minPerSide, this.maxPriceDa,  Set<Feature> features = const <Feature>{}, this.favoritesOnly = false}): _features = features,super._();
  

/// Pitch must fit at least this many players per side (null = any).
@override final  int? minPerSide;
/// Price per hour at most (null = any).
@override final  int? maxPriceDa;
 final  Set<Feature> _features;
@override@JsonKey() Set<Feature> get features {
  if (_features is EqualUnmodifiableSetView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_features);
}

@override@JsonKey() final  bool favoritesOnly;

/// Create a copy of PitchFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PitchFilterCopyWith<_PitchFilter> get copyWith => __$PitchFilterCopyWithImpl<_PitchFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PitchFilter&&(identical(other.minPerSide, minPerSide) || other.minPerSide == minPerSide)&&(identical(other.maxPriceDa, maxPriceDa) || other.maxPriceDa == maxPriceDa)&&const DeepCollectionEquality().equals(other.features, _features)&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minPerSide,maxPriceDa,const DeepCollectionEquality().hash(_features),favoritesOnly);
}

@override
String toString() {
    return 'PitchFilter(minPerSide: $minPerSide, maxPriceDa: $maxPriceDa, features: $features, favoritesOnly: $favoritesOnly)';
}


}

/// @nodoc
abstract mixin class _$PitchFilterCopyWith<$Res> implements $PitchFilterCopyWith<$Res> {
  factory _$PitchFilterCopyWith(_PitchFilter value, $Res Function(_PitchFilter) _then) = __$PitchFilterCopyWithImpl;
@override @useResult
$Res call({
 int? minPerSide, int? maxPriceDa, Set<Feature> features, bool favoritesOnly
});




}
/// @nodoc
class __$PitchFilterCopyWithImpl<$Res>
    implements _$PitchFilterCopyWith<$Res> {
  __$PitchFilterCopyWithImpl(this._self, this._then);

  final _PitchFilter _self;
  final $Res Function(_PitchFilter) _then;

/// Create a copy of PitchFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minPerSide = freezed,Object? maxPriceDa = freezed,Object? features = null,Object? favoritesOnly = null,}) {
  return _then(_PitchFilter(
minPerSide: freezed == minPerSide ? _self.minPerSide : minPerSide // ignore: cast_nullable_to_non_nullable
as int?,maxPriceDa: freezed == maxPriceDa ? _self.maxPriceDa : maxPriceDa // ignore: cast_nullable_to_non_nullable
as int?,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as Set<Feature>,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
