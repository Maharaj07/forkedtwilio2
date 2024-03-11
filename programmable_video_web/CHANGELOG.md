## 1.1.1

- Updates maximum supported SDK version to Dart 3.x
- Changed JSMap `Iterator` interop fields, and params of `iteratorToList`, and `iteratorForEach` to `dynamic`, to fix an issue after Chromium version 122 was released. Thanks to [Kai Chen @kai1300009](https://gitlab.com/kai1300009) for finding this part of the solution.
- Changed video registration for local and remote views according to the [findings](https://gitlab.com/twilio-flutter/programmable-video/-/issues/261#note_1798305671) of [Raphael @CabraKill](https://gitlab.com/CabraKill). Thanks for the implementation.

## 1.1.0

- Fixed some small annotation errors in the Web implementation.
- Implemented `VideoRenderMode` as required by the platform interface. For backwards compatibility, it defaults to `VideoRenderMode.BALANCED`.

## 1.0.1

- Stop video and audio tracks on disconnect.

## 1.0.0

- Released web to stable.

## 1.0.0-alpha.1

- Initial pre-release of the web implementation.
