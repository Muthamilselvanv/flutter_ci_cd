# Test strategy

The fast CI suite is run with:

```powershell
flutter test
```

It currently contains:

- `test/unit/`: fast tests for configuration, endpoint construction, controller
  state, successful responses, and handled failures. These use fake services and
  never call a real backend.
- `test/widget_test.dart`: a widget smoke test that builds the app and verifies
  its initial environment UI.

Future integration tests belong in `integration_test/`. They should exercise a
small number of critical journeys on an emulator against a controlled test
environment. They should not call production, and they should run separately
from the fast pull-request suite because emulator startup is comparatively
expensive and more failure-prone.

Recommended execution policy:

| Test type | Pull request | Push to `dev`/`main` | Release |
| --- | --- | --- | --- |
| Unit | Required | Required | Required |
| Widget | Required | Required | Required |
| Integration | Later: selected smoke tests | Later: required smoke tests | Later: required critical journeys |
