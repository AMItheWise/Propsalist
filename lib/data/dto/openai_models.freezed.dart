// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'openai_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpenAIChatMessage {

 String get role; String get content;
/// Create a copy of OpenAIChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAIChatMessageCopyWith<OpenAIChatMessage> get copyWith => _$OpenAIChatMessageCopyWithImpl<OpenAIChatMessage>(this as OpenAIChatMessage, _$identity);

  /// Serializes this OpenAIChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAIChatMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,content);

@override
String toString() {
  return 'OpenAIChatMessage(role: $role, content: $content)';
}


}

/// @nodoc
abstract mixin class $OpenAIChatMessageCopyWith<$Res>  {
  factory $OpenAIChatMessageCopyWith(OpenAIChatMessage value, $Res Function(OpenAIChatMessage) _then) = _$OpenAIChatMessageCopyWithImpl;
@useResult
$Res call({
 String role, String content
});




}
/// @nodoc
class _$OpenAIChatMessageCopyWithImpl<$Res>
    implements $OpenAIChatMessageCopyWith<$Res> {
  _$OpenAIChatMessageCopyWithImpl(this._self, this._then);

  final OpenAIChatMessage _self;
  final $Res Function(OpenAIChatMessage) _then;

/// Create a copy of OpenAIChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? content = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenAIChatMessage].
extension OpenAIChatMessagePatterns on OpenAIChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAIChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAIChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAIChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAIChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAIChatMessage() when $default != null:
return $default(_that.role,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  String content)  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatMessage():
return $default(_that.role,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  String content)?  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatMessage() when $default != null:
return $default(_that.role,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAIChatMessage implements OpenAIChatMessage {
  const _OpenAIChatMessage({required this.role, required this.content});
  factory _OpenAIChatMessage.fromJson(Map<String, dynamic> json) => _$OpenAIChatMessageFromJson(json);

@override final  String role;
@override final  String content;

/// Create a copy of OpenAIChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAIChatMessageCopyWith<_OpenAIChatMessage> get copyWith => __$OpenAIChatMessageCopyWithImpl<_OpenAIChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAIChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAIChatMessage&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,content);

@override
String toString() {
  return 'OpenAIChatMessage(role: $role, content: $content)';
}


}

/// @nodoc
abstract mixin class _$OpenAIChatMessageCopyWith<$Res> implements $OpenAIChatMessageCopyWith<$Res> {
  factory _$OpenAIChatMessageCopyWith(_OpenAIChatMessage value, $Res Function(_OpenAIChatMessage) _then) = __$OpenAIChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String role, String content
});




}
/// @nodoc
class __$OpenAIChatMessageCopyWithImpl<$Res>
    implements _$OpenAIChatMessageCopyWith<$Res> {
  __$OpenAIChatMessageCopyWithImpl(this._self, this._then);

  final _OpenAIChatMessage _self;
  final $Res Function(_OpenAIChatMessage) _then;

/// Create a copy of OpenAIChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? content = null,}) {
  return _then(_OpenAIChatMessage(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OpenAIChatRequest {

 String get model; List<OpenAIChatMessage> get messages;@JsonKey(name: 'max_tokens') int get maxTokens;
/// Create a copy of OpenAIChatRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAIChatRequestCopyWith<OpenAIChatRequest> get copyWith => _$OpenAIChatRequestCopyWithImpl<OpenAIChatRequest>(this as OpenAIChatRequest, _$identity);

  /// Serializes this OpenAIChatRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAIChatRequest&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,const DeepCollectionEquality().hash(messages),maxTokens);

@override
String toString() {
  return 'OpenAIChatRequest(model: $model, messages: $messages, maxTokens: $maxTokens)';
}


}

/// @nodoc
abstract mixin class $OpenAIChatRequestCopyWith<$Res>  {
  factory $OpenAIChatRequestCopyWith(OpenAIChatRequest value, $Res Function(OpenAIChatRequest) _then) = _$OpenAIChatRequestCopyWithImpl;
@useResult
$Res call({
 String model, List<OpenAIChatMessage> messages,@JsonKey(name: 'max_tokens') int maxTokens
});




}
/// @nodoc
class _$OpenAIChatRequestCopyWithImpl<$Res>
    implements $OpenAIChatRequestCopyWith<$Res> {
  _$OpenAIChatRequestCopyWithImpl(this._self, this._then);

  final OpenAIChatRequest _self;
  final $Res Function(OpenAIChatRequest) _then;

/// Create a copy of OpenAIChatRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? messages = null,Object? maxTokens = null,}) {
  return _then(_self.copyWith(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<OpenAIChatMessage>,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenAIChatRequest].
extension OpenAIChatRequestPatterns on OpenAIChatRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAIChatRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAIChatRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAIChatRequest value)  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAIChatRequest value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String model,  List<OpenAIChatMessage> messages, @JsonKey(name: 'max_tokens')  int maxTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAIChatRequest() when $default != null:
return $default(_that.model,_that.messages,_that.maxTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String model,  List<OpenAIChatMessage> messages, @JsonKey(name: 'max_tokens')  int maxTokens)  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatRequest():
return $default(_that.model,_that.messages,_that.maxTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String model,  List<OpenAIChatMessage> messages, @JsonKey(name: 'max_tokens')  int maxTokens)?  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatRequest() when $default != null:
return $default(_that.model,_that.messages,_that.maxTokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAIChatRequest implements OpenAIChatRequest {
  const _OpenAIChatRequest({required this.model, required final  List<OpenAIChatMessage> messages, @JsonKey(name: 'max_tokens') required this.maxTokens}): _messages = messages;
  factory _OpenAIChatRequest.fromJson(Map<String, dynamic> json) => _$OpenAIChatRequestFromJson(json);

@override final  String model;
 final  List<OpenAIChatMessage> _messages;
@override List<OpenAIChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey(name: 'max_tokens') final  int maxTokens;

/// Create a copy of OpenAIChatRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAIChatRequestCopyWith<_OpenAIChatRequest> get copyWith => __$OpenAIChatRequestCopyWithImpl<_OpenAIChatRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAIChatRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAIChatRequest&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,model,const DeepCollectionEquality().hash(_messages),maxTokens);

@override
String toString() {
  return 'OpenAIChatRequest(model: $model, messages: $messages, maxTokens: $maxTokens)';
}


}

/// @nodoc
abstract mixin class _$OpenAIChatRequestCopyWith<$Res> implements $OpenAIChatRequestCopyWith<$Res> {
  factory _$OpenAIChatRequestCopyWith(_OpenAIChatRequest value, $Res Function(_OpenAIChatRequest) _then) = __$OpenAIChatRequestCopyWithImpl;
@override @useResult
$Res call({
 String model, List<OpenAIChatMessage> messages,@JsonKey(name: 'max_tokens') int maxTokens
});




}
/// @nodoc
class __$OpenAIChatRequestCopyWithImpl<$Res>
    implements _$OpenAIChatRequestCopyWith<$Res> {
  __$OpenAIChatRequestCopyWithImpl(this._self, this._then);

  final _OpenAIChatRequest _self;
  final $Res Function(_OpenAIChatRequest) _then;

/// Create a copy of OpenAIChatRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? messages = null,Object? maxTokens = null,}) {
  return _then(_OpenAIChatRequest(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<OpenAIChatMessage>,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OpenAIChatChoice {

 OpenAIChatMessage get message;
/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAIChatChoiceCopyWith<OpenAIChatChoice> get copyWith => _$OpenAIChatChoiceCopyWithImpl<OpenAIChatChoice>(this as OpenAIChatChoice, _$identity);

  /// Serializes this OpenAIChatChoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAIChatChoice&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'OpenAIChatChoice(message: $message)';
}


}

/// @nodoc
abstract mixin class $OpenAIChatChoiceCopyWith<$Res>  {
  factory $OpenAIChatChoiceCopyWith(OpenAIChatChoice value, $Res Function(OpenAIChatChoice) _then) = _$OpenAIChatChoiceCopyWithImpl;
@useResult
$Res call({
 OpenAIChatMessage message
});


$OpenAIChatMessageCopyWith<$Res> get message;

}
/// @nodoc
class _$OpenAIChatChoiceCopyWithImpl<$Res>
    implements $OpenAIChatChoiceCopyWith<$Res> {
  _$OpenAIChatChoiceCopyWithImpl(this._self, this._then);

  final OpenAIChatChoice _self;
  final $Res Function(OpenAIChatChoice) _then;

/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as OpenAIChatMessage,
  ));
}
/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAIChatMessageCopyWith<$Res> get message {
  
  return $OpenAIChatMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpenAIChatChoice].
extension OpenAIChatChoicePatterns on OpenAIChatChoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAIChatChoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAIChatChoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAIChatChoice value)  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatChoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAIChatChoice value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatChoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OpenAIChatMessage message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAIChatChoice() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OpenAIChatMessage message)  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatChoice():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OpenAIChatMessage message)?  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatChoice() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAIChatChoice implements OpenAIChatChoice {
  const _OpenAIChatChoice({required this.message});
  factory _OpenAIChatChoice.fromJson(Map<String, dynamic> json) => _$OpenAIChatChoiceFromJson(json);

@override final  OpenAIChatMessage message;

/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAIChatChoiceCopyWith<_OpenAIChatChoice> get copyWith => __$OpenAIChatChoiceCopyWithImpl<_OpenAIChatChoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAIChatChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAIChatChoice&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'OpenAIChatChoice(message: $message)';
}


}

/// @nodoc
abstract mixin class _$OpenAIChatChoiceCopyWith<$Res> implements $OpenAIChatChoiceCopyWith<$Res> {
  factory _$OpenAIChatChoiceCopyWith(_OpenAIChatChoice value, $Res Function(_OpenAIChatChoice) _then) = __$OpenAIChatChoiceCopyWithImpl;
@override @useResult
$Res call({
 OpenAIChatMessage message
});


@override $OpenAIChatMessageCopyWith<$Res> get message;

}
/// @nodoc
class __$OpenAIChatChoiceCopyWithImpl<$Res>
    implements _$OpenAIChatChoiceCopyWith<$Res> {
  __$OpenAIChatChoiceCopyWithImpl(this._self, this._then);

  final _OpenAIChatChoice _self;
  final $Res Function(_OpenAIChatChoice) _then;

/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_OpenAIChatChoice(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as OpenAIChatMessage,
  ));
}

/// Create a copy of OpenAIChatChoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenAIChatMessageCopyWith<$Res> get message {
  
  return $OpenAIChatMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// @nodoc
mixin _$OpenAIChatResponse {

 List<OpenAIChatChoice> get choices;
/// Create a copy of OpenAIChatResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenAIChatResponseCopyWith<OpenAIChatResponse> get copyWith => _$OpenAIChatResponseCopyWithImpl<OpenAIChatResponse>(this as OpenAIChatResponse, _$identity);

  /// Serializes this OpenAIChatResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenAIChatResponse&&const DeepCollectionEquality().equals(other.choices, choices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(choices));

@override
String toString() {
  return 'OpenAIChatResponse(choices: $choices)';
}


}

/// @nodoc
abstract mixin class $OpenAIChatResponseCopyWith<$Res>  {
  factory $OpenAIChatResponseCopyWith(OpenAIChatResponse value, $Res Function(OpenAIChatResponse) _then) = _$OpenAIChatResponseCopyWithImpl;
@useResult
$Res call({
 List<OpenAIChatChoice> choices
});




}
/// @nodoc
class _$OpenAIChatResponseCopyWithImpl<$Res>
    implements $OpenAIChatResponseCopyWith<$Res> {
  _$OpenAIChatResponseCopyWithImpl(this._self, this._then);

  final OpenAIChatResponse _self;
  final $Res Function(OpenAIChatResponse) _then;

/// Create a copy of OpenAIChatResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? choices = null,}) {
  return _then(_self.copyWith(
choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<OpenAIChatChoice>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenAIChatResponse].
extension OpenAIChatResponsePatterns on OpenAIChatResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenAIChatResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenAIChatResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenAIChatResponse value)  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenAIChatResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OpenAIChatResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OpenAIChatChoice> choices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenAIChatResponse() when $default != null:
return $default(_that.choices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OpenAIChatChoice> choices)  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatResponse():
return $default(_that.choices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OpenAIChatChoice> choices)?  $default,) {final _that = this;
switch (_that) {
case _OpenAIChatResponse() when $default != null:
return $default(_that.choices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenAIChatResponse implements OpenAIChatResponse {
  const _OpenAIChatResponse({required final  List<OpenAIChatChoice> choices}): _choices = choices;
  factory _OpenAIChatResponse.fromJson(Map<String, dynamic> json) => _$OpenAIChatResponseFromJson(json);

 final  List<OpenAIChatChoice> _choices;
@override List<OpenAIChatChoice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}


/// Create a copy of OpenAIChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenAIChatResponseCopyWith<_OpenAIChatResponse> get copyWith => __$OpenAIChatResponseCopyWithImpl<_OpenAIChatResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenAIChatResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenAIChatResponse&&const DeepCollectionEquality().equals(other._choices, _choices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_choices));

@override
String toString() {
  return 'OpenAIChatResponse(choices: $choices)';
}


}

/// @nodoc
abstract mixin class _$OpenAIChatResponseCopyWith<$Res> implements $OpenAIChatResponseCopyWith<$Res> {
  factory _$OpenAIChatResponseCopyWith(_OpenAIChatResponse value, $Res Function(_OpenAIChatResponse) _then) = __$OpenAIChatResponseCopyWithImpl;
@override @useResult
$Res call({
 List<OpenAIChatChoice> choices
});




}
/// @nodoc
class __$OpenAIChatResponseCopyWithImpl<$Res>
    implements _$OpenAIChatResponseCopyWith<$Res> {
  __$OpenAIChatResponseCopyWithImpl(this._self, this._then);

  final _OpenAIChatResponse _self;
  final $Res Function(_OpenAIChatResponse) _then;

/// Create a copy of OpenAIChatResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? choices = null,}) {
  return _then(_OpenAIChatResponse(
choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<OpenAIChatChoice>,
  ));
}


}

// dart format on
