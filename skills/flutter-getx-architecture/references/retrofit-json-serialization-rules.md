# Retrofit and Json Serializable Rules

## Core Principle

The API layer must be generated and declarative.

Use:

- `retrofit` to define REST endpoints
- `json_serializable` to define DTO serialization
- `result_dart` to express repository success and failure without ad-hoc exception flow
- `build_runner` to generate implementation files

Do not write manual REST clients and ad-hoc JSON parsing unless the user explicitly asks for an exception.

## Package Expectations

Typical dependencies:

- `dio`
- `retrofit`
- `json_annotation`
- `result_dart`

Typical dev dependencies:

- `retrofit_generator`
- `json_serializable`
- `build_runner`

## Required Structure

Prefer a shared app-level data layer when Retrofit clients and DTOs are reused:

```text
app/
  data/
    datasources/
      profile_api.dart
      auth_api.dart
    failures/
      app_failure.dart
    models/
      api_response.dart
      response_meta.dart
      profile_response.dart
      update_profile_request.dart
    repositories/
      profile_repository.dart
```

If the backend wraps payloads in a common envelope such as `meta + data`, define one shared generic model for that envelope and reuse it across features.

Keep repository placement centralized even when one API area grows. Growth may justify more files, but not a second repository location convention.

## Retrofit Client Rule

Declare APIs with `@RestApi()` and method annotations such as:

- `@GET`
- `@POST`
- `@PUT`
- `@PATCH`
- `@DELETE`

Example shape:

```dart
@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @GET('/profile')
  Future<ProfileResponse> getProfile();
}
```

If the API uses an envelope, prefer:

```dart
@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String? baseUrl}) = _ProfileApi;

  @GET('/profile')
  Future<ApiResponse<ProfileResponse>> getProfile();
}
```

Rules:

- keep endpoint definitions in API files only
- inject `Dio` from composition setup
- avoid building URLs manually in controllers or repositories
- do not name the custom envelope `Response<T>` because that collides with `dio.Response`
- keep shared Retrofit clients in the centralized data layer unless they are clearly feature-scoped

## Json Serializable Rule

Every request and response DTO should use `@JsonSerializable()`.

Example shape:

```dart
@JsonSerializable()
class ProfileResponse {
  const ProfileResponse({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
```

Rules:

- do not handwrite repetitive JSON mapping
- keep transport models separate from complex UI state
- add explicit converters only when the API shape truly needs them

## Generic Envelope Rule

When the backend returns a wrapped payload such as:

```json
{
  "meta": { "message": "ok" },
  "data": { ... }
}
```

use a shared generic envelope model such as `ApiResponse<T>` or `BaseResponse<T>`.

Prefer:

```dart
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    required this.meta,
    required this.data,
  });

  final ResponseMeta meta;
  final T data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
```

Rules:

- prefer `ApiResponse<T>` or `BaseResponse<T>` over `Response<T>`
- enable `genericArgumentFactories: true` for the generic wrapper
- define the envelope once in a shared location if many features use the same API contract
- keep `meta` as its own typed model when the shape is stable
- use feature DTOs inside `data`, for example `ApiResponse<UserDto>`

This generic pattern aligns with `json_serializable` support for `generic_argument_factories` and with Retrofit's typed return models.

## Repository Rule

Repositories should depend on Retrofit APIs, not on raw HTTP calls.

Prefer:

- repository receives an API client
- repository unwraps or maps `ApiResponse<T>` into domain-friendly results for the controller when appropriate
- repository returns `ResultDart<T, AppFailure>` or a project-specific equivalent typed result contract

Avoid:

- controller receiving `Dio`
- view receiving DTOs and transport concerns directly if a mapping boundary is needed
- leaking `DioException` or arbitrary thrown exceptions directly into controllers

## Result Dart Rule

Use `result_dart` at the repository boundary, not as a replacement for the transport envelope.

Recommended separation:

- Retrofit client returns DTOs or `ApiResponse<T>`
- repository maps transport output into `ResultDart<DomainOrUiModel, AppFailure>`
- controller consumes `ResultDart` and updates UI state explicitly

Prefer a typed failure model such as `AppFailure`, `NetworkFailure`, or `ApiFailure` instead of generic string errors.

Example shape:

```dart
Future<ResultDart<UserProfile, AppFailure>> getProfile() async {
  try {
    final response = await profileApi.getProfile();
    return Success(response.data.toDomain());
  } on DioException catch (error) {
    return Failure(AppFailure.network(error));
  } catch (error) {
    return Failure(AppFailure.unknown(error));
  }
}
```

Rules:

- keep `ResultDart` at repository or use-case boundaries
- do not expose raw transport exceptions to the controller
- do not wrap `ResultDart` inside another generic success wrapper unless the project already requires it
- keep one consistent failure hierarchy for the app
- treat `ApiResponse<T>` and `ResultDart<T, F>` as different concerns: transport schema versus application flow

## Generation Rule

After changing Retrofit clients or JSON models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If the repo already uses `watch` or a wrapper command, preserve the project convention.

## Decision Rule

When unsure:

1. define the DTO with `@JsonSerializable()`
2. if the backend wraps payloads, define `ApiResponse<T>` with `genericArgumentFactories: true`
3. place shared DTOs and Retrofit APIs under the centralized data layer
4. define the endpoint with `@RestApi()`
5. inject the API into a repository
6. map transport output to `ResultDart<T, AppFailure>`
7. keep the controller unaware of transport details
