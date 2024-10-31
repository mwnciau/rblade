## 1.2.2 [UNRELEASED]
- Update dependencies
- Fixed redundant unfreezing of interpolated string

## 1.2.1 [2024-10-31]
- Fix issue with @props directive when defining multiple properties without braces

## 1.2.0 [2024-10-22]
- Add support for custom directives (#2)
- Add support for helper functions that use block content (#14)
- Change to use frozen string literals
- Fix issue with no space after starting ERB style tag
- Ignore any @ directives that don't have a handler
- Make @endruby directive case insensitive and allow underscore

## 1.1.1 [2024-08-23]
- Remove requirement for including braces in `@props` directive

## 1.1.0 [2024-08-23]
- Add `@eachWithIndex` directive
- Fix attribute manager output of attributes with no value (#10)

## 1.0.5 [2024-08-14]
- Allow use of variables in @method directive

## 1.0.4 [2024-08-14]
- Fix printing ruby member variables (#8)

## 1.0.3 [2024-08-10]
- Add GitHub CI
- Add support for the Rails `raw` method for outputting unescaped HTML

## 1.0.2 [2024-08-09]
- Fix non-string `@props` defaults being converted to slots

## 1.0.1 [2024-08-09]
- Automatically detect when properties are used as slots
- Change `_required` to `required` in @props

## 1.0.0 [2024-08-06]
- Add quick reference and examples
- Add @shouldRender directive
- Add support for ERB style `<%==` unsafe prints
- Fix bugs with statement argument error handling
- Remove deprecated "breakIf" and "nextIf" statements
- Rename "echo" compilers to "print"
- Update README

## 0.6.1 [2024-08-02]
- Fix broken build

## 0.6.0 [2024-08-02]
- Add attributes.class method
- Add `@blank?`, `@defined?`, `@empty?`, `@nil?` and `@present?`
- Add `@method`, `@patch`, `@put` and `@delete`
- Add `@pushif` and `@prependif`
- Add string methods to slots
- Fix whitespaces causing problems between case and when statements
- Pass Rails `session`, `cookies`, `flash` and `params` variables into components

## 0.5.0 [2024-07-31]
- Add support for slots
- Change @props to only add valid variable names to global scope
- Change @props to remove from attributes array

## 0.4.0 [2024-07-29]
- Add @class and @style statements
- Add @env and @production statements
- Add @once, @pushOnce and @prependOnce statements
- Add @verbatim statement
- Add readme and license
- Improve boundaries of statements
- Make statements ignore underscore and case
- Merge @break & @breakif and @next & @nextif

## 0.3.0 [2024-07-26]
- Add support for index component files
- Add support for relative components
- Add support for unsafe closing tags
- Allow direct access to attributes underlying hash
- Fix each statement with a key value pair
- Improve output of binary HTML attributes
- Improve performance of components
- Switch to .rblade file extensions

## 0.2.5 [2024-07-23]
- Improve how @props sets local variables

## 0.2.4 [2024-07-23]
- Improve merging of classes

## 0.2.3 [2024-07-23]
- Fix attributes in components that have multiple lines

## 0.2.2 [2024-07-23]
- Change comments to be compiled first

## 0.2.1 [2024-07-23]
- Add support for attributes pass through in components

## 0.2.0 [2024-07-23]
- Fix slots being calculated without parent's context
- Add @props statement
- Add attributes, class and style manager

## 0.1.0 [2024-07-22]
- Initial release