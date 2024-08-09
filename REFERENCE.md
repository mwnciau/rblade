<a name="quick-reference"></a>
# Quick Reference

A table below provides a quick overview of RBlade syntax and directives. The [readme](README.md) has a more in depth look at RBlade's capabilities.

| Syntax                                                  | Description                                                                               |
|:--------------------------------------------------------|:------------------------------------------------------------------------------------------|
| `{{ RUBY_EXPRESSION }}`<br/>`<%= RUBY_EXPRESSION %>`    | Print the string value of the ruby expression, escaping HTML special characters           |
| `{!! RUBY_EXPRESSION !!}`<br/>`<%== RUBY_EXPRESSION %>` | Print the string value of the ruby expression, _without_ escaping HTML special characters |
| `@ruby( RUBY_EXPRESSION )`                              | Execute an inline ruby expression                                                         |
| `@ruby ... @endRuby`                                    | Execute a block of ruby code                                                              |
| `{{-- ... --}}`<br/>`<%# ... %>`                        | Comments, removed from the compiled template with no performance cost                     |
| `@verbatim ... @endVerbatim`                            | Print the given content without parsing RBlade directives                                 |

<a name="quick-reference-components"></a>
## Components

By default, RBlade will look for components in the `app/views/components` folder. Additionally, components in the `layout` namespace are found in the `app/views/layouts` folder, and components in the `view` namespace are found in the `app/views` folder.

| Syntax                                                   | Description                                                                                                                                |
|:---------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------|
| `<x-component.name/>`                                    | Render the component found at `app/views/components/name{.rblade,.html.rblade}` or `app/views/components/name/index{.rblade,.html.rblade}` |
| `<x-layout::name/>`                                      | Render the "name" component found in the "layout" namespace folder                                                                         |
| `<x-component.name>...</x-component.name>`               | Render the component with the given slot content                                                                                           |
| `<x-component.name>...<//>`                              | Short closing tag syntax (note: this bypasses some sanity checking during compilation)                                                     |
| `<x-name attribute="STRING"/>`                           | Pass a string value to a component                                                                                                         |
| `<x-name :attribute="RUBY_EXPRESSION"/>`                 | Pass a ruby expression, executed in the local scope, to a component                                                                        |
| `<x-name :attribute/>`                                   | Pass the `attribute` local variable into a component                                                                                       |
| `<x-name @class({'bg-red-600': is_error})/>`             | Conditionally pass classes to a component                                                                                                  |
| `<x-name @style({'bg-red-600': is_error})/>`             | Conditionally pass styles to a component                                                                                                   |
| `<x-name attribute/>`                                    | Pass an attribute to a component with value `true`                                                                                         |
| `<x-name {{ attributes }}/>`                             | Pass attributes to a child component                                                                                                       |
| `@props({header: "Header"})`                             | Remove `header` from the attributes Hash and introduce it as a local variable, using the specified value as a default                      |
| `@props({header: required})`                             | Remove `header` from the attributes Hash and introduce it as a local variable, raising an error if it is not set                           |
| `{{ slot }}`                                             | Output the block content passed into the current component                                                                                 |
| `<x-name><x-slot::header><h1>Header</h1><//>Content<//>` | Pass a named block to a component                                                                                                          |
| `{{ header }}`                                           | Output the contents of a named block                                                                                                       |
| `<div {{ header.attributes }}>`                          | Output the attributes passed into a named block                                                                                            |

<a name="quick-reference-attributes"></a>
## Attributes

The attributes variable is an instance of a class that manages attributes. As well as the methods used in the examples below, you can use any method belonging to the Hash class.

| Syntax                                                                   | Description                                                                                                |
|:-------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|
| `<div {{ attributes }}>`                                                 | Print the contents of attributes as HTML attributes                                                        |
| `<div {{ attributes.merge({class: "text-black", type: "button"}) }}>`    | Merge in additional attributes, combining the `:class` and `:style`, and setting defaults for other values |
| `<div {{ attributes.except(['type']) }}>`                                | Output the attributes array excluding the given keys                                                       |
| `<div {{ attributes.only(['type']) }}>`                                  | Output only the given keys of the attributes array                                                         |
| `<div {{ attributes.filter { \|key, value\| key.start_with? "on:" } }}>` | Output the attributes for which the block returns true                                                     |
| `<div @class({'bg-red-600': is_error})>`                                 | Conditionally print classes in an HTML class attribute                                                     |
| `<div @style({'bg-red-600': is_error})>`                                 | Conditionally print styles in an HTML style attribute                                                      |

<a name="quick-reference-conditions"></a>
## Conditions

| Syntax                                                                | Description                                                                                                        |
|:----------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------|
| `@if( RUBY_EXPRESSION ) ... @endIf`                                   | Compiles to a Ruby if statement                                                                                    |
| `@if( RUBY_EXPRESSION ) ... @else ... @endIf`                         | Compiles to a Ruby if/else statement                                                                               |
| `@if( RUBY_EXPRESSION ) ... @elsif( RUBY_EXPRESSION ) ... @endIf`     | Compiles to a Ruby if/elsif statement                                                                              |
| `@unless( RUBY_EXPRESSION ) ... @endunless`                           | Compiles to a Ruby unless statement                                                                                |
| `@case( RUBY_EXPRESSION ) @when(1) ... @when(2) ... @else ... @endIf` | Compiles to a Ruby case statement                                                                                  |
| `@blank?( RUBY_EXPRESSION ) ... @endBlank?`                           | Compiles to a Ruby if statement that calls `blank?` method on the given expression                                 |
| `@defined?( RUBY_EXPRESSION ) ... @endDefined?`                       | Compiles to a Ruby if statement that calls `defined?` function on the given expression                             |
| `@empty?( RUBY_EXPRESSION ) ... @endEmpty?`                           | Compiles to a Ruby if statement that calls `empty?` method on the given expression                                 |
| `@nil?( RUBY_EXPRESSION ) ... @endNil?`                               | Compiles to a Ruby if statement that calls `nil?` method on the given expression                                   |
| `@present?( RUBY_EXPRESSION ) ... @endPresent?`                       | Compiles to a Ruby if statement that calls `present?` method on the given expression                               |
| `@env(['development', 'test']) ... @endEnv`                           | Compiles to a Ruby if statement that checks if the current Rails environment matches any of the given environments |
| `@production ... @endProduction`                                      | Shortcut for `@env('production')`                                                                                  |
| `@once ... @endOnce`                                                  | Render the given block the first time it appears in the template                                                   |
| `@once('unique key') ... @endOnce`                                    | Render the given block the first time "unique key" is used in the template                                         |

<a name="quick-reference-loops"></a>
## Loops

| Syntax                                                | Description                                                                                                |
|:------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|
| `@while( looping ) ... @endWhile`                     | Compiles to a Ruby while statement                                                                         |
| `@until( finished ) ... @endUntil`                    | Compiles to a Ruby until statement                                                                         |
| `@for( i in 1..10 ) ... @endFor`                      | Compiles to a Ruby for loop                                                                                |
| `@each( i in 1..10 ) ... @endEach`                    | Calls `each` on the given collection, with `\|i\|` as the block argument                                   |
| `@each( key, value in {a: 1} ) ... @endEach`          | Calls `each` on the given Hash, with `\|key, value\|` as the block arguments                               |
| `@forElse( i in 1..10 ) ... @empty ... @endForElse`   | Compiles to a for loop as above, but the block after `@empty` is printed if the given collection is empty  |
| `@eachElse( i in 1..10 ) ... @empty ... @endEachElse` | Compiles to a each loop as above, but the block after `@empty` is printed if the given collection is empty |
| `@break`                                              | Break out of the current loop                                                                              |
| `@next`                                               | Go to the next iteration in the current loop                                                               |
| `@break( RUBY_EXPRESSION )`                           | Break out of the current loop if the expression evaluate to true                                           |
| `@next( RUBY_EXPRESSION )`                            | Go to the next iteration in the current loop if the expression evaluate to true                            |

<a name="quick-reference-forms"></a>
## Forms

| Syntax                           | Description                                                                                                      |
|:---------------------------------|:-----------------------------------------------------------------------------------------------------------------|
| `@old(:email, user[:email])`     | Fetches `:email` from the params Hash, defaulting to the user's email if it doesn't exist                        |
| `@method('PATCH')`               | Prints a hidden input setting the HTTP request type to the given value using the Rails MethodOverride middleware |
| `@DELETE`                        | Shortcut for `@method('DELETE')`                                                                                 |
| `@PATCH`                         | Shortcut for `@method('PATCH')`                                                                                  |
| `@PUT`                           | Shortcut for `@method('PUT')`                                                                                    |
| `@checked( RUBY_EXPRESSION )`    | Prints "checked" if the ruby expression evaluates to true                                                        |
| `@disabled( RUBY_EXPRESSION )`   | Prints "disabled" if the ruby expression evaluates to true                                                       |
| `@readonly( RUBY_EXPRESSION )`   | Prints "readonly" if the ruby expression evaluates to true                                                       |
| `@required( RUBY_EXPRESSION )`   | Prints "required" if the ruby expression evaluates to true                                                       |
| `@selected( RUBY_EXPRESSION )`   | Prints "selected" if the ruby expression evaluates to true                                                       |

<a name="quick-reference-stacks"></a>
## Stacks

Stacks are a way of rendering content outside of the usual document order. For example, you could define a "sidebar" stack, then you'd be able to add content to that sidebar from anywhere else in the site.

Note that the stack is printed once the current view or component finishes. 

| Syntax                                                      | Description                                                                                 |
|:------------------------------------------------------------|:--------------------------------------------------------------------------------------------|
| `@stack('scripts')`                                         | Start a stack with the name 'scripts'. Stacks can be pushed to elsewhere in the code.       |
| `@push('scripts') ... @endPush`                             | Add block content to the 'scripts' stack                                                    |
| `@prepend('scripts') ... @endPrepend`                       | Add block content to the start of the 'scripts' stack                                       |
| `@pushIf(RUBY_EXPRESSION, 'scripts') ... @endPushIf`        | Add block content to the 'scripts' stack if the expression evaluate to true                 |
| `@prependIf(RUBY_EXPRESSION, 'scripts') ... @endprependIf`  | Add block content to the start of the 'scripts' stack if the expression evaluate to true    |
| `@pushOnce('scripts') ... @endPushOnce`                     | Add block content to the 'scripts' stack only once                                          |
| `@prependOnce('scripts') ... @endPrependOnce`               | Add block content to the start of the 'scripts' stack only once                             |
| `@pushOnce('scripts', 'unique key') ... @endPushOnce`       | Add block content to the 'scripts' stack the first time "unique key" is pushed              |
| `@prependOnce('scripts', 'unique key') ... @endPrependOnce` | Add block content to the start of the 'scripts' stack the first time "unique key" is pushed |

## Tips

* Except for `@push`, `@prepend` and their variants, all end directives can simply be replaced with `@end` if preferred:
    -  `@nil?(...) ... @endnil?`
    -  `@nil?(...) ... @endnil`
    -  `@nil?(...) ... @end`
* Except for `@ruby` and `@verbatim`, directives are case insensitive and can contain underscores. The following are identical:
    - `@pushonce`
    - `@pushOnce`
    - `@PushOnce` 
    - `@push_once` 
    - `@PUSHONCE` 
