# Contributing

Contributions are welcome through focused issues and pull requests.

## Development

Use Nim 2.0.0 or newer. From the package root run:

```sh
nimble check
nimble test
nimble examples
nimble docs
```

Keep imports side-effect free, return styled strings instead of writing to the
terminal, and test ANSI and Unicode behavior by terminal cells rather than byte
length. New public APIs need doc comments, validation tests, and a finite
example where useful.

By contributing, you agree that your contribution is licensed under the MIT
license in `LICENSE`. Do not submit code whose license is unknown or
incompatible; record incorporated third-party material in
`THIRD_PARTY_NOTICES.md`.

