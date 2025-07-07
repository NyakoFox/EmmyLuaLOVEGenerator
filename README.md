# EmmyLua LÖVE Generator

A script to generate [LÖVE](https://love2d.org/) API autocomplete files for [EmmyLua](https://github.com/EmmyLuaLs/emmylua-analyzer-rust), based off of [Emmy-love-api](https://github.com/EmmyLua/Emmy-love-api).

## Instructions

1. Download this repository.
2. Download the version of the [LÖVE API](https://github.com/love2d-community/love-api) that you want.
3. Ensure that the `api` folder exists. If not, create it.
4. Copy both the LÖVE API's `modules` folder and the `love_api.lua` file into this repository's root directory.
5. Run `genEmmyAPI.lua` using your computer's installation of Lua. Ex. `lua genEmmyAPI.lua`.
6. Copy the `api` folder into your project's source folder, the same folder where `main.lua` is (you can rename it whatever you want, it doesn't have to be called `api`).
7. In your project, add the directory you just created into your `.emmyrc.json`, in the array in `workspace` -> `library`.

Once you start or refresh your IDE (might be automatic) you should have autocomplete and quick documentation for LÖVE!

## Other LÖVE versions

When you want to regenerate the autocomplete files, delete the contents of the `api` folder (not the folder itself!) and redo the steps.

## Changes from Emmy-love-api

- Nothing included in this repository by default to avoid people using old versions of the LÖVE API
- Optional arguments are now properly generated
  - Marked as optional in the `---@param` defines
  - Appends `(Defaults to <default>.)` to the description

- Should now work with modern EmmyLua:
  - Definition files now use `---@meta` rather than classes
  - `m.function` and `return m` were removed, now relying on meta syntax
  - All files have a namespace definition for `love`, meaning that `love.Object` is the type, which will not conflict with your own `Object` type
  - Enums are now `---@alias`es rather than (unannotated) tables. Originally I just added `---@enum`, but you can't actually access those tables in LÖVE.

- Added console output
- Styling changes
  - Replaced generated tabs with spaces
  - Indents should now be more consistent
  - None of the generated files should have default warnings

- Small organization changes

## Credits

Original script by [@tangzx](https://github.com/tangzx)

Modifications & original README by [@kindfulkirby](https://github.com/kindfulkirby)

Updated for modern EmmyLua by [@NyakoFox](https://github.com/NyakoFox)
