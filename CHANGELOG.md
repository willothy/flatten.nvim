# Changelog

## [0.5.1](https://github.com/willothy/flatten.nvim/compare/v0.5.0...v0.5.1) (2024-01-26)


### Bug Fixes

* check int return value of `vim.fn.has` ([#92](https://github.com/willothy/flatten.nvim/issues/92)) ([0338960](https://github.com/willothy/flatten.nvim/commit/0338960b47e01f7295f89ebef60a7d45e9f2b3e9))
* handle absolute paths on windows ([#90](https://github.com/willothy/flatten.nvim/issues/90)) ([d1fff3c](https://github.com/willothy/flatten.nvim/commit/d1fff3c380ff93f55f27d02168cc7952cc473f8c))
* **lint:** remove unused initializer for is_absolute ([1153797](https://github.com/willothy/flatten.nvim/commit/11537971a22cd03456dcc7b38efea5df11d90cfd))

## [0.5.0](https://github.com/willothy/flatten.nvim/compare/v0.4.1...v0.5.0) (2023-11-28)


### ⚠ BREAKING CHANGES

* make wezterm/kitty feature opt-in, disabled by default

### Features

* smart open should prefer alternative window ([#83](https://github.com/willothy/flatten.nvim/issues/83)) ([8a88333](https://github.com/willothy/flatten.nvim/commit/8a883330dd9436f010430e78ae7cb449037c79ba))


### Code Refactoring

* make wezterm/kitty feature opt-in, disabled by default ([797b02a](https://github.com/willothy/flatten.nvim/commit/797b02a6cbadfc0bd0675d2f469439c2ca3cf267))

## [0.4.1](https://github.com/willothy/flatten.nvim/compare/v0.4.0...v0.4.1) (2023-09-24)


### Bug Fixes

* default should_nest ([11f9960](https://github.com/willothy/flatten.nvim/commit/11f9960aa4f5994f20675e3bcc31a4c19ceafb4f))
* don't escape filenames ([6236aa9](https://github.com/willothy/flatten.nvim/commit/6236aa988a8aeab1c4a59c92615492ec241d33c7)), closes [#70](https://github.com/willothy/flatten.nvim/issues/70)
* only open new tab if tab option is set ([9f08ac1](https://github.com/willothy/flatten.nvim/commit/9f08ac10d5cdc9b48e3087869774b4578de1d19e)), closes [#66](https://github.com/willothy/flatten.nvim/issues/66)
* **smart-open:** only avoid curwin if it's a term ([6813ad3](https://github.com/willothy/flatten.nvim/commit/6813ad3c49b74fbeb5bc851c7d269b611fc86dd3))

## [v0.4.0](https://github.com/willothy/flatten.nvim/tree/v0.4.0) (2023-08-10)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/v0.3.0...v0.4.0)

**Merged pull requests:**

- Release v0.4.0 [\#62](https://github.com/willothy/flatten.nvim/pull/62) ([willothy](https://github.com/willothy))
- docs: improve toggleterm example [\#58](https://github.com/willothy/flatten.nvim/pull/58) ([loqusion](https://github.com/loqusion))
- fix: provide winnr of newly opened file [\#55](https://github.com/willothy/flatten.nvim/pull/55) ([willothy](https://github.com/willothy))
- Performance and misc fixes [\#54](https://github.com/willothy/flatten.nvim/pull/54) ([willothy](https://github.com/willothy))
- Miscellaneous features and fixes [\#53](https://github.com/willothy/flatten.nvim/pull/53) ([IndianBoy42](https://github.com/IndianBoy42))
- feat: get buffer id from the open function [\#46](https://github.com/willothy/flatten.nvim/pull/46) ([sassanh](https://github.com/sassanh))
- fix\(setup\): default to an empty table when `opt` is not provided [\#44](https://github.com/willothy/flatten.nvim/pull/44) ([utilyre](https://github.com/utilyre))

## [v0.3.0](https://github.com/willothy/flatten.nvim/tree/v0.3.0) (2023-04-09)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/v0.2.0...v0.3.0)

**Implemented enhancements:**

- Command passthrough [\#37](https://github.com/willothy/flatten.nvim/pull/37) ([willothy](https://github.com/willothy))

**Fixed bugs:**

- fix: errors when file is in wildignore [\#25](https://github.com/willothy/flatten.nvim/pull/25) ([stevearc](https://github.com/stevearc))

**Merged pull requests:**

- fix: support for pre-0.9 Neovim instances [\#38](https://github.com/willothy/flatten.nvim/pull/38) ([davidmh](https://github.com/davidmh))
- fix: absolute paths should not use the guest cwd [\#34](https://github.com/willothy/flatten.nvim/pull/34) ([davidmh](https://github.com/davidmh))
- Read and pass full argv options [\#33](https://github.com/willothy/flatten.nvim/pull/33) ([davidmh](https://github.com/davidmh))
- fix: prioritize guest cwd [\#30](https://github.com/willothy/flatten.nvim/pull/30) ([davidmh](https://github.com/davidmh))
- feat: open in alternate window [\#29](https://github.com/willothy/flatten.nvim/pull/29) ([willothy](https://github.com/willothy))
- Update README.md to fix lazy.nvim config example [\#23](https://github.com/willothy/flatten.nvim/pull/23) ([catgoose](https://github.com/catgoose))
- feat: force blocking from cmdline [\#22](https://github.com/willothy/flatten.nvim/pull/22) ([willothy](https://github.com/willothy))
- fix: close guest bufs before host opens files [\#21](https://github.com/willothy/flatten.nvim/pull/21) ([willothy](https://github.com/willothy))
- fix: paths with spaces on Windows [\#20](https://github.com/willothy/flatten.nvim/pull/20) ([willothy](https://github.com/willothy))

## [v0.2.0](https://github.com/willothy/flatten.nvim/tree/v0.2.0) (2023-03-16)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/v0.1.2...v0.2.0)

**Implemented enhancements:**

- feat: Allow piping from term into new buffer [\#8](https://github.com/willothy/flatten.nvim/pull/8) ([willothy](https://github.com/willothy))

**Merged pull requests:**

- feat: default to open in current window instead of tab [\#14](https://github.com/willothy/flatten.nvim/pull/14) ([willothy](https://github.com/willothy))
- refactor: use Lua `[[]]` multiline string syntax [\#13](https://github.com/willothy/flatten.nvim/pull/13) ([nyngwang](https://github.com/nyngwang))
- doc: mention unception author in license/readme [\#6](https://github.com/willothy/flatten.nvim/pull/6) ([willothy](https://github.com/willothy))

## [v0.1.2](https://github.com/willothy/flatten.nvim/tree/v0.1.2) (2023-03-12)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/v0.1.1...v0.1.2)

**Merged pull requests:**

- feat\(config\): Add settings for opening windows [\#4](https://github.com/willothy/flatten.nvim/pull/4) ([willothy](https://github.com/willothy))

## [v0.1.1](https://github.com/willothy/flatten.nvim/tree/v0.1.1) (2023-03-11)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- v0.1.1 \(Builtin server\) [\#2](https://github.com/willothy/flatten.nvim/pull/2) ([willothy](https://github.com/willothy))
- chore: update readme for 0.1.1 \(Builtin server\) [\#1](https://github.com/willothy/flatten.nvim/pull/1) ([willothy](https://github.com/willothy))

## [v0.1.0](https://github.com/willothy/flatten.nvim/tree/v0.1.0) (2023-03-11)

[Full Changelog](https://github.com/willothy/flatten.nvim/compare/4a72062a4ff97a556b0d0a95348b49028f2b9ecf...v0.1.0)
