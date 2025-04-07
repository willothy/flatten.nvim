# Changelog

## [1.0.0](https://github.com/jam1015/flatten.nvim/compare/v0.5.1...v1.0.0) (2025-04-07)


### ⚠ BREAKING CHANGES

* **config:** rename `callbacks` to `hooks`
* drop support for nvim <= 0.10
* fully typed config and API, use tables for callback ctx
* make wezterm/kitty feature opt-in, disabled by default
* should_nest callback and nest by cwd
* use fn.bufadd, pass bufnrs to open fn

### Features

* add `is_guest` utility method ([6d93630](https://github.com/jam1015/flatten.nvim/commit/6d93630e010fd52104b6e77610631edee34defc5))
* add a `should_block` callback ([d8d3999](https://github.com/jam1015/flatten.nvim/commit/d8d3999f371f05412c130bcf8fffd91c2634f379))
* allow passing data from guest to host ([d3e3529](https://github.com/jam1015/flatten.nvim/commit/d3e3529c23740a5411da3614e1ca3f35eb968fc9))
* Allow piping from term into new buffer ([73a0a02](https://github.com/jam1015/flatten.nvim/commit/73a0a0242feeef8e2e456e11956bf04bbfaeaf06))
* allow remote use of quickfix mode (`nvim -q`) ([de9f7b0](https://github.com/jam1015/flatten.nvim/commit/de9f7b06d324ca5b54aa72b31bcbb483d3ae8048)), closes [#94](https://github.com/jam1015/flatten.nvim/issues/94)
* command passthrough ([1514583](https://github.com/jam1015/flatten.nvim/commit/1514583676a79da4093bfa51d67d423301a5aec1))
* **config:** Add settings for opening windows ([6e7a179](https://github.com/jam1015/flatten.nvim/commit/6e7a179aa3acfc5b817ec189dcbd21fa9636a58f))
* **config:** rename `callbacks` to `hooks` ([738e16b](https://github.com/jam1015/flatten.nvim/commit/738e16bc003f8cb531354fc169e2102cd255eaba))
* custom pipe_path ([e4fec8d](https://github.com/jam1015/flatten.nvim/commit/e4fec8de73efc246028c469c4398ba8a0c79e02b))
* default to open in current window instead of tab ([3280f6f](https://github.com/jam1015/flatten.nvim/commit/3280f6f2db822132384e310dfdc1cb943efe8a16))
* diff mode with -d flag ([#63](https://github.com/jam1015/flatten.nvim/issues/63)) ([667989a](https://github.com/jam1015/flatten.nvim/commit/667989afb7a07e54d5ce11cb43197679ea0dbefa))
* force blocking from cmdline ([cad0d39](https://github.com/jam1015/flatten.nvim/commit/cad0d3960b31bb238ec42b976db4cc05ccb4c166))
* get buffer id from the open function ([a64f606](https://github.com/jam1015/flatten.nvim/commit/a64f60686a03aa93b32320e4c8de59875ffc965f))
* kitty/wezterm support out of the box ([ed0937e](https://github.com/jam1015/flatten.nvim/commit/ed0937e081d50ab73b1bead7383a6ad62c110d7e))
* no_files callback ([c2e366e](https://github.com/jam1015/flatten.nvim/commit/c2e366eb601a6db68848476f9155156139653303))
* open in alternate window ([ca60030](https://github.com/jam1015/flatten.nvim/commit/ca60030f8706b296a9ed2c5953c3cc4711d6386c))
* opt-out for cmd passthrough ([55c1853](https://github.com/jam1015/flatten.nvim/commit/55c1853de0c562bcdeaf9a52b5e4adccc86a2db3))
* **opts:** Nested instance when launched with no args ([081095e](https://github.com/jam1015/flatten.nvim/commit/081095e3abbfeae03b74e134053e8ef48c751932)), closes [#41](https://github.com/jam1015/flatten.nvim/issues/41)
* pass v:argv into the window.open function ([0779249](https://github.com/jam1015/flatten.nvim/commit/07792495244b2fb5a05bd3ee01a28ea78d80d95c))
* provide guest cwd to `window.open` function ([169fcc0](https://github.com/jam1015/flatten.nvim/commit/169fcc0d3588d9643e36a7d25fef093c78a1dc74))
* send stdin_buf as the third argument of the open callback ([e3e99bd](https://github.com/jam1015/flatten.nvim/commit/e3e99bdeaaf470b1829b70f93797b3dc98804de0))
* should_nest callback and nest by cwd ([d03db44](https://github.com/jam1015/flatten.nvim/commit/d03db44ee3428f4997bf314571eb1c9e6ef1991c))
* smart open mode to avoid special buffers ([8a91836](https://github.com/jam1015/flatten.nvim/commit/8a91836a029cd1defe985eb907572b89bb588a5c))
* smart open should prefer alternative window ([#83](https://github.com/jam1015/flatten.nvim/issues/83)) ([8a88333](https://github.com/jam1015/flatten.nvim/commit/8a883330dd9436f010430e78ae7cb449037c79ba))
* support command passthrough without files ([87fc4e0](https://github.com/jam1015/flatten.nvim/commit/87fc4e088ba21b73b25a151be9c2319cac5e6890))
* use fn.bufadd, pass bufnrs to open fn ([d323c33](https://github.com/jam1015/flatten.nvim/commit/d323c337aeb2e2cc876d5afb098462a4c89f343b))


### Bug Fixes

* `timeout must be &gt;= 0` for vim.wait ([814f3d2](https://github.com/jam1015/flatten.nvim/commit/814f3d2661a60034719f129d5ec064c1d686e76d))
* absolute paths should not use the guest cwd ([bac6a6a](https://github.com/jam1015/flatten.nvim/commit/bac6a6ac7817a6483bdea7f1f907f1fc314a019b))
* add checks for list_bufs ([2bff175](https://github.com/jam1015/flatten.nvim/commit/2bff175c50dc66491874d3b9030c0de95e2f4597))
* Blocking and nonblocking both working ([3f25be7](https://github.com/jam1015/flatten.nvim/commit/3f25be786bcf097681ac653db02751b3135a7c29))
* **blocking:** Fix issue with blocking ([3ef1c00](https://github.com/jam1015/flatten.nvim/commit/3ef1c006342209de23850e4b29d10faa3d9c4d8b))
* **blocking:** Fix issue with blocking autocmds ([9a654e1](https://github.com/jam1015/flatten.nvim/commit/9a654e1e9cba6bd80c594bd12b85d930c8d72316))
* **blocking:** No longer enters duplicate nested session ([f03fec3](https://github.com/jam1015/flatten.nvim/commit/f03fec337d97c7027fd471ddf967d95e3de8e446))
* check int return value of `vim.fn.has` ([#92](https://github.com/jam1015/flatten.nvim/issues/92)) ([0338960](https://github.com/jam1015/flatten.nvim/commit/0338960b47e01f7295f89ebef60a7d45e9f2b3e9))
* close guest bufs before host opens files ([0cc20a4](https://github.com/jam1015/flatten.nvim/commit/0cc20a4bb9dd43a3a35aa40c2b3d351933ae1cbc))
* default should_nest ([11f9960](https://github.com/jam1015/flatten.nvim/commit/11f9960aa4f5994f20675e3bcc31a4c19ceafb4f))
* don't escape filenames ([6236aa9](https://github.com/jam1015/flatten.nvim/commit/6236aa988a8aeab1c4a59c92615492ec241d33c7)), closes [#70](https://github.com/jam1015/flatten.nvim/issues/70)
* ensure flatten respects `nest_if_no_args` ([c271eb8](https://github.com/jam1015/flatten.nvim/commit/c271eb8972a934870f2c3b5832bf72e970bdc199))
* errors when file is in wildignore ([84b5f9f](https://github.com/jam1015/flatten.nvim/commit/84b5f9f70b64228a149cd45d2f48ce98b046eb0c))
* Escape guest paths on Windows ([362bd0e](https://github.com/jam1015/flatten.nvim/commit/362bd0ebe6b0b6961044eaeb3e71956a46f125e4))
* handle absolute paths on windows ([#90](https://github.com/jam1015/flatten.nvim/issues/90)) ([d1fff3c](https://github.com/jam1015/flatten.nvim/commit/d1fff3c380ff93f55f27d02168cc7952cc473f8c))
* **lint:** remove unused initializer for is_absolute ([1153797](https://github.com/jam1015/flatten.nvim/commit/11537971a22cd03456dcc7b38efea5df11d90cfd))
* only execute BufEnter autocmds once ([97228f7](https://github.com/jam1015/flatten.nvim/commit/97228f78dfee042c18ecce0d788c91f59e770f31))
* only open new tab if tab option is set ([9f08ac1](https://github.com/jam1015/flatten.nvim/commit/9f08ac10d5cdc9b48e3087869774b4578de1d19e)), closes [#66](https://github.com/jam1015/flatten.nvim/issues/66)
* opening files in current window did not switch buffers ([99582fc](https://github.com/jam1015/flatten.nvim/commit/99582fc587b1860a9373587cb5bab02474b3a6ab))
* opening files in sub directories when the cwd changes ([2b63f92](https://github.com/jam1015/flatten.nvim/commit/2b63f9209b7254f357494fc59d7ed70609940849))
* **os/compat:** check `jit.os == "Windows"` instead of `has("win32")` ([22fc170](https://github.com/jam1015/flatten.nvim/commit/22fc1708bbc16f508ddfd4220c55b9eaca025288))
* paths with spaces on Windows ([a64378f](https://github.com/jam1015/flatten.nvim/commit/a64378fd3aa3213bc028971edb0d764db35edbdf))
* **paths:** Fix files in guest pwd failing to open ([16914b7](https://github.com/jam1015/flatten.nvim/commit/16914b79f2db04b0771d8ba59326bd93c212a9b8))
* pre-0.9 support for postcmds ([3508bea](https://github.com/jam1015/flatten.nvim/commit/3508beaa48d316937d8332d17f7ddc1b7d3f9a83))
* prioritize guest cwd ([fc9af19](https://github.com/jam1015/flatten.nvim/commit/fc9af19a02594bc0ef32a6b8e609e4bd0a9ce1f1))
* provide winnr of newly opened file ([c6f3950](https://github.com/jam1015/flatten.nvim/commit/c6f3950d1b0e40fb267366c356d99ed5ab10a15a))
* remove the `fast_events` param of `vim.wait` ([8bded0b](https://github.com/jam1015/flatten.nvim/commit/8bded0b08492bf4e902452daf28c168d205747f1))
* remove uses of buffer and window type aliases ([cc3d8f7](https://github.com/jam1015/flatten.nvim/commit/cc3d8f79b27e6619136147b35935111be5a83335))
* return false on error in core ([f7e5935](https://github.com/jam1015/flatten.nvim/commit/f7e5935fb38a09305abcef18592c20160a18aedd))
* return value from rpc call ([ab2e108](https://github.com/jam1015/flatten.nvim/commit/ab2e1085c731dd296a56e9670218083726337df6))
* revert to qa! over os.exit to exit cleanly ([f1618e0](https://github.com/jam1015/flatten.nvim/commit/f1618e04c477a74bc0aba465a0d96ae5baee67c4))
* **rpc:** return `ok, sock` from `M.sockconnect` ([d78d4a1](https://github.com/jam1015/flatten.nvim/commit/d78d4a1beed5f1f4d1c560fefea7cb2f82f7ff8c))
* set buffer when using the `smart` open strategy ([45cd774](https://github.com/jam1015/flatten.nvim/commit/45cd7745c024d52ff0711222c20ee1607b228ac0))
* **setup:** default to an empty table when `opt` is not provided ([28db604](https://github.com/jam1015/flatten.nvim/commit/28db6048a509c9653cb4a4c734e03f412139aa11))
* **smart-open:** only avoid curwin if it's a term ([6813ad3](https://github.com/jam1015/flatten.nvim/commit/6813ad3c49b74fbeb5bc851c7d269b611fc86dd3))
* stop waiting if/when rpc channel is closed ([4607ac0](https://github.com/jam1015/flatten.nvim/commit/4607ac09bed5c783877989977e856534a481e09f))
* support for pre-0.9 Neovim instances ([ebcdce4](https://github.com/jam1015/flatten.nvim/commit/ebcdce44806c887ace7640b3b0f2845a3c5f4d30))
* take care of nil value returned by open function ([6f23fab](https://github.com/jam1015/flatten.nvim/commit/6f23fabbb0a5ad9f89a3125ef7e4b34219185d96))
* trim scheme from file uri ([9e55edc](https://github.com/jam1015/flatten.nvim/commit/9e55edc2e2692e9e151de40444926c5ab0bd0ce5))
* use `0xffffffffffffffff` instead of `math.huge` ([9203fc6](https://github.com/jam1015/flatten.nvim/commit/9203fc65134866fc31318b74dc92a12a97028f34))
* use `rpc.connect()` instead of `guest.sockconnect()` ([754a7fa](https://github.com/jam1015/flatten.nvim/commit/754a7fafa8de6dc9dcc0c2fae25abf469efd489a))
* use default interval for `vim.wait` ([4258a0a](https://github.com/jam1015/flatten.nvim/commit/4258a0a21df130c9c148602763bb8800e452d180))
* use rpc module functions in default hooks ([6a91020](https://github.com/jam1015/flatten.nvim/commit/6a910201c3c565c2973006c489de5a49fbc33bb1))
* use tabedit for opening files in a new tab ([5c6ca13](https://github.com/jam1015/flatten.nvim/commit/5c6ca13ac96b563df27eb42997ebc24c1b9f2079))


### Performance Improvements

* use loop instead of `vim.tbl_*` ([17396d6](https://github.com/jam1015/flatten.nvim/commit/17396d6eb04051a9aa41647f7492c2fcd201d5d7))


### Reverts

* **9779e4b:** revert example config change ([c986f98](https://github.com/jam1015/flatten.nvim/commit/c986f98bc1d1e2365dfb2e97dda58ca5d0ae24ae))


### Documentation

* update breaking change notice in readme ([d5d7cef](https://github.com/jam1015/flatten.nvim/commit/d5d7cef314218a39d3e444dd5b689d7413fab5a7))


### Code Refactoring

* drop support for nvim &lt;= 0.10 ([cc3d8f7](https://github.com/jam1015/flatten.nvim/commit/cc3d8f79b27e6619136147b35935111be5a83335))
* fully typed config and API, use tables for callback ctx ([ffb2979](https://github.com/jam1015/flatten.nvim/commit/ffb29792da8800b01c299e56fb00d8c96d5198a6))
* make wezterm/kitty feature opt-in, disabled by default ([797b02a](https://github.com/jam1015/flatten.nvim/commit/797b02a6cbadfc0bd0675d2f469439c2ca3cf267))

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
