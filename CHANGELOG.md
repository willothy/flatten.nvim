# Changelog

## [1.0.0](https://github.com/willothy/flatten.nvim/compare/v0.5.1...v1.0.0) (2024-12-30)


### ⚠ BREAKING CHANGES

* **config:** rename `callbacks` to `hooks`
* drop support for nvim <= 0.10
* fully typed config and API, use tables for callback ctx

### Features

* allow passing data from guest to host ([d3e3529](https://github.com/willothy/flatten.nvim/commit/d3e3529c23740a5411da3614e1ca3f35eb968fc9))
* allow remote use of quickfix mode (`nvim -q`) ([de9f7b0](https://github.com/willothy/flatten.nvim/commit/de9f7b06d324ca5b54aa72b31bcbb483d3ae8048)), closes [#94](https://github.com/willothy/flatten.nvim/issues/94)
* **config:** rename `callbacks` to `hooks` ([738e16b](https://github.com/willothy/flatten.nvim/commit/738e16bc003f8cb531354fc169e2102cd255eaba))
* support command passthrough without files ([87fc4e0](https://github.com/willothy/flatten.nvim/commit/87fc4e088ba21b73b25a151be9c2319cac5e6890))


### Bug Fixes

* `timeout must be &gt;= 0` for vim.wait ([814f3d2](https://github.com/willothy/flatten.nvim/commit/814f3d2661a60034719f129d5ec064c1d686e76d))
* opening files in current window did not switch buffers ([99582fc](https://github.com/willothy/flatten.nvim/commit/99582fc587b1860a9373587cb5bab02474b3a6ab))
* **os/compat:** check `jit.os == "Windows"` instead of `has("win32")` ([22fc170](https://github.com/willothy/flatten.nvim/commit/22fc1708bbc16f508ddfd4220c55b9eaca025288))
* remove the `fast_events` param of `vim.wait` ([8bded0b](https://github.com/willothy/flatten.nvim/commit/8bded0b08492bf4e902452daf28c168d205747f1))
* remove uses of buffer and window type aliases ([cc3d8f7](https://github.com/willothy/flatten.nvim/commit/cc3d8f79b27e6619136147b35935111be5a83335))
* return value from rpc call ([ab2e108](https://github.com/willothy/flatten.nvim/commit/ab2e1085c731dd296a56e9670218083726337df6))
* set buffer when using the `smart` open strategy ([45cd774](https://github.com/willothy/flatten.nvim/commit/45cd7745c024d52ff0711222c20ee1607b228ac0))
* stop waiting if/when rpc channel is closed ([4607ac0](https://github.com/willothy/flatten.nvim/commit/4607ac09bed5c783877989977e856534a481e09f))
* trim scheme from file uri ([9e55edc](https://github.com/willothy/flatten.nvim/commit/9e55edc2e2692e9e151de40444926c5ab0bd0ce5))
* use `0xffffffffffffffff` instead of `math.huge` ([9203fc6](https://github.com/willothy/flatten.nvim/commit/9203fc65134866fc31318b74dc92a12a97028f34))
* use `rpc.connect()` instead of `guest.sockconnect()` ([754a7fa](https://github.com/willothy/flatten.nvim/commit/754a7fafa8de6dc9dcc0c2fae25abf469efd489a))
* use default interval for `vim.wait` ([4258a0a](https://github.com/willothy/flatten.nvim/commit/4258a0a21df130c9c148602763bb8800e452d180))
* use rpc module functions in default hooks ([6a91020](https://github.com/willothy/flatten.nvim/commit/6a910201c3c565c2973006c489de5a49fbc33bb1))


### Documentation

* update breaking change notice in readme ([d5d7cef](https://github.com/willothy/flatten.nvim/commit/d5d7cef314218a39d3e444dd5b689d7413fab5a7))


### Code Refactoring

* drop support for nvim &lt;= 0.10 ([cc3d8f7](https://github.com/willothy/flatten.nvim/commit/cc3d8f79b27e6619136147b35935111be5a83335))
* fully typed config and API, use tables for callback ctx ([ffb2979](https://github.com/willothy/flatten.nvim/commit/ffb29792da8800b01c299e56fb00d8c96d5198a6))

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
