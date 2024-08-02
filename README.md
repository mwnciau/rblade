# RBlade Templates

- [RBlade Templates](#rblade-templates)
  * [Introduction](#introduction)
  * [Displaying Data](#displaying-data)
    + [HTML Entity Encoding](#html-entity-encoding)
    + [Blade and JavaScript Frameworks](#blade-and-javascript-frameworks)
      - [The `@verbatim` Directive](#the-at-verbatim-directive)
  * [RBlade Directives](#rblade-directives)
    + [If Statements](#if-statements)
      - [Environment Directives](#environment-directives)
    + [Case Statements](#case-statements)
    + [Loops](#loops)
    + [Conditional Classes & Styles](#conditional-classes-and-styles)
    + [Additional Attributes](#additional-attributes)
    + [The `@once` Directive](#the-once-directive)
    + [Raw Ruby](#raw-ruby)
    + [Comments](#comments)
  * [Components](#components)
    + [Rendering Components](#rendering-components)
      - [Namespaces](#namespaces)
    + [Passing Data to Components](#passing-data-to-components)
      - [Component Properties](#component-properties)
      - [Short Attribute Syntax](#short-attribute-syntax)
      - [Escaping Attribute Rendering](#escaping-attribute-rendering)
    + [Component Attributes](#component-attributes)
      - [Default & Merged Attributes](#default-and-merged-attributes)
      - [Non-Class Attribute Merging](#non-class-attribute-merging)
      - [Conditionally Merge Classes](#conditionally-merge-classes)
      - [Retrieving and Filtering Attributes](#retrieving-and-filtering-attributes)
    + [Slots](#slots)
      - [Slot Attributes](#slot-attributes)
    + [Registering Additional Component Directories](#registering-additional-component-directories)
    + [Index Components](#index-components)
  * [Forms](#forms)
    + [Old Input](#old-input)
    + [Method Field](#method-field)
  * [Stacks](#stacks)

<a name="introduction"></a>
## Introduction

RBlade is a simple, yet powerful templating engine for Ruby on Rails, inspired by [Laravel Blade](https://laravel.com/docs/blade). Unlike some templating engines, RBlade does not restrict you from using plain Ruby code in your templates. Blade template files use the `.rblade` file extension and are typically stored in the `app/views` directory.

<a name="displaying-data"></a>
## Displaying Data

You may display data that is passed to your RBlade views by wrapping the variable in curly braces. For example, given the following controller method:

```ruby
def index
  name = "Samantha"
end
```

You may display the contents of the `name` variable like so:

```rblade
Hello, {{ name }}.
```

> [!NOTE]  
> RBlade's `{{ }}` print statements are automatically sent through Rails' `h` function to prevent XSS attacks.

You are not limited to displaying the contents of the variables passed to the view. You may also print the results of any Ruby function. In fact, you can put any Ruby code you wish inside of a RBlade print directive:

```rblade
The current UNIX timestamp is {{ Time.now.to_i }}.
```

<a name="html-entity-encoding"></a>
### HTML Entity Encoding

By default, RBlade `{{ }}` statements are automatically sent through Rails' `h` function to prevent XSS attacks. If you do not want your data to be escaped, you may use the following syntax:

```rblade
Hello, {!! name !!}.
```

> [!WARNING]  
> Be very careful when echoing content that is supplied by users of your application. You should typically use the escaped, double curly brace syntax to prevent XSS attacks when displaying user supplied data.

<a name="blade-and-javascript-frameworks"></a>
### Blade and JavaScript Frameworks

Since many JavaScript frameworks also use "curly" braces to indicate a given expression should be displayed in the browser, you may use the `@` symbol to inform the RBlade rendering engine an expression should remain untouched. For example:

```rblade
<h1>Laravel</h1>

Hello, @{{ name }}.
```

In this example, the `@` symbol will be removed by Blade; however, `{{ name }}` expression will remain untouched by the RBlade engine, allowing it to be rendered by your JavaScript framework.

The `@` symbol may also be used to escape RBlade directives:

```rblade
{{-- Blade template --}}
@@if()

<!-- HTML output -->
@if()
```

<a name="the-at-verbatim-directive"></a>
#### The `@verbatim` Directive

If you are displaying JavaScript variables in a large portion of your template, you may wrap the HTML in the `@verbatim` directive so that you do not have to prefix each Blade print directive with an `@` symbol:

```rblade
@verbatim
    <div class="container">
        Hello, {{ name }}.
    </div>
@endverbatim
```

<a name="blade-directives"></a>
## RBlade Directives

In addition to template inheritance and displaying data, RBlade also provides convenient shortcuts for common Ruby control structures, such as conditional statements and loops. These shortcuts provide a very clean, terse way of working with Ruby control structures while also remaining familiar to their ruby counterparts.

> [!NOTE]  
> RBlade directives are case insensitive and ignore underscores, so depending on your preference, all of `@endif`, `@endIf` and `@end_if` are identical.

<a name="if-statements"></a>
### If Statements

You may construct `if` statements using the `@if`, `@elseIf`, `@else`, `@endIf`, `@unless`, and `@endUnless` directives. These directives function identically to their Ruby counterparts:

```rblade
@unless(records.nil?)
  @if (records.count === 1)
      I have one record!
  @elseIf (records.count > 1)
      I have multiple records!
  @else
      I don't have any records!
  @endIf
@endUnless
```

In addition to the conditional directives above, the `@blank?`, `defined?`, `@empty?`, `@nil?` and `@present` directives may be used as convenient shortcuts:

```rblade
@present?(records)
    // records is defined and is not nil
@else
    // These directives are shortcuts to if statements so @else may be used
@endempty?
```

<a name="environment-directives"></a>
#### Environment Directives

You may check if the application is running in the production environment using the `@production` directive:

```rblade
@production
    // Production specific content...
@endProduction
```

Or, you may determine if the application is running in a specific environment using the `@env` directive:

```rblade
@env('staging')
    // The application is running in "staging"...
@endEnv

@env(['staging', 'production'])
    // The application is running in "staging" or "production"...
@endEnv
```

<a name="switch-statements"></a>
### Case Statements

Case statements can be constructed using the `@case`, `@when`, `@else` and `@endCase` directives:

```rblade
@case(i)
@when(1)
    First case...
@when(2)
    Second case...
@else
    Default case...
@endCase
```

<a name="loops"></a>
### Loops

In addition to conditional statements, RBlade provides simple directives for working with Ruby's loop structures:

```rblade
@for (i in 0...10)
    The current value is {{ i }}
@endFor

{{-- Compiles to users.each do |user| ... --}}
@each (user in users)
    <p>This is user {{ user.id }}</p>
@endEach

@forElse (name in [])
    <li>{{ name }}</li>
@empty
    <p>No names</p>
@endForElse

@eachElse (user in users)
    <li>{{ user.name }}</li>
@empty
    <p>No users</p>
@endEachElse

@while (true)
    <p>I'm looping forever.</p>
@endWhile
```

When using loops you can also skip the current iteration or end the loop using the `@next` and `@break` directives:

```rblade
for (user in users)
    @if (user.type == 1)
        @next
    @endIf

    <li>{{ user.name }}</li>

    @if (user.number == 5)
        @break
    @endIf
@endFor
```

You may also include the continuation or break condition within the directive declaration:

```rblade
@for (user in users)
    @next(user.type == 1)

    <li>{{ user.name }}</li>

    @break(user.number == 5)
@endFor
```

<a name="conditional-classes-and-styles"></a>
### Conditional Classes & Styles

The `@class` directive conditionally adds CSS classes. The directive accepts a `Hash` of classes where the key contains the class or classes you wish to add, and the value is a boolean expression:

```rblade
@ruby
    isActive = false;
    hasError = true;
@endRuby

<span @class({
    "p-4": true,
    "font-bold": isActive,
    "text-gray-500": !isActive,
    "bg-red": hasError,
})></span>

<span class="p-4 text-gray-500 bg-red"></span>
```

Likewise, the `@style` directive may be used to conditionally add inline CSS styles to an HTML element:

```rblade
@ruby
    isActive = true;
@endRuby

<span @style({
    "background-color: red": true,
    "font-weight: bold" => isActive,
})></span>

<span style="background-color: red; font-weight: bold;"></span>
```

<a name="additional-attributes"></a>
### Additional Attributes

For convenience, you may use the `@checked` directive to easily indicate if a given HTML checkbox input is "checked". This directive will print `checked` if the provided condition evaluates to `true`:

```rblade
<input type="checkbox"
  name="active"
  value="active"
  @checked(user.active)) />
```

Likewise, the `@selected` directive may be used to indicate if a given select option should be "selected":

```rblade
<select name="version">
  @each (version in product.versions)
    <option value="{{ version }}" @selected(version == selectedVersion)>
      {{ version }}
    </option>
  @endEach
</select>
```

Additionally, the `@disabled` directive may be used to indicate if a given element should be "disabled":

```rblade
<button type="submit" @disabled(isDisabled)>Submit</button>
```

Moreover, the `@readonly` directive may be used to indicate if a given element should be "readonly":

```rblade
<input type="email"
  name="email"
  value="email@laravel.com"
  @readonly(!user.isAdmin) />
```

In addition, the `@required` directive may be used to indicate if a given element should be "required":

```rblade
<input type="text"
  name="title"
  value="title"
  @required(user.isAdmin) />
```

<a name="the-once-directive"></a>
### The `@once` Directive

The `@once` directive allows you to define a portion of the template that will only be evaluated once per rendering cycle. This may be useful for pushing a given piece of JavaScript into the page's header using [stacks](#stacks). For example, if you are rendering a given [component](#components) within a loop, you may wish to only push the JavaScript to the header the first time the component is rendered:

```rblade
@once
    @push('scripts')
        <script>
            // Your custom JavaScript...
        </script>
    @endPush
@endOnce
```

Since the `@once` directive is often used in conjunction with the `@push` or `@prepend` directives, the `@pushOnce` and `@prependOnce` directives are available for your convenience:

```rblade
@pushOnce('scripts')
    <script>
        {{-- Your javascript --}}
    </script>
@endPushOnce
```

Additionally, you can pass an argument to the `@once` directive, or a second argument to the `@pushonce` and `@prependonce` directives to set the key that is used to determine if that block has already been output: 

```rblade
@once(:heading)
    <h1>Home page</h1>
@endOnce

{{-- This block will not be output --}}
@once(:heading)
    <h1>Some other title</h1>
@endOnce
```

> [!NOTE]  
> The keys you use for `@once`, `@pushOnce` and `@prependOnce` are shared.

<a name="raw-ruby"></a>
### Raw Ruby

In some situations, it's useful to embed Ruby code into your views. You can use the RBlade `@ruby` directive to execute a block of plain Ruby within your template:

```rblade
@ruby
    counter = 1;
@endRuby
```

<a name="comments"></a>
### Comments

RBlade also allows you to define comments in your views. However, unlike HTML comments, RBlade comments are not included in the HTML returned by your application. These comments are removed from the cached views so they have no performance downsides.

```rblade
{{-- This comment will not be present in the rendered HTML --}}
```

<a name="components"></a>
## Components

Components are a way of including sub-views into your templates. To illustrate how to use them, we will create a simple `alert` component.

First, we will create a new `alert.rblade` file in the `app/views/components/forms` directory. Templates in the `app/views/components` directory and its subdirectories are are automatically discovered as components, so no further registration is required. Both `.rblade` and `.html.rblade` are valid extensions for RBlade components.

Once your component has been created, it may be rendered using its tag alias:

```rblade
<x-forms.alert/>
```

<a name="rendering-components"></a>
### Rendering Components

To display a component, you may use a Blade component tag within one of your Blade templates. Blade component tags start with the string `x-` followed by the kebab case name of the component class:

```rblade
{{-- Render the `alert` component in app/views/components/ --}}
<x-alert/>

{{-- Render the `user-profile` component in app/views/components/ --}}
<x-user-profile/>
```

If the component class is in a subdirectory of `app/views/components`, you can use the `.` character to indicate directory nesting. For example, for the component `app/views/components/form/inputs/text.rblade`, we render it like so:

```rblade
{{-- Render the `text` component in app/views/components/form/inputs/ --}}
<x-form.inputs.text/>
```

<a name="namespaces"></a>
#### Namespaces

When writing components for your own application, components are automatically discovered within the `app/views/components` directory. Additionally, layouts in the `app/views/layouts` directory are automatically discovered with the `layout` namespace, and all views in the `app/views` directory are discovered with the `view` namespace.

Namespaced components can be rendered using the namespace as a prefix to the name separated by "::":

```rblade
{{-- Render the `app` component in app/views/layouts/ --}}
<x-layout::app/>

{{-- Render the `home` component in app/views/ --}}
<x-view::home/>
```

<a name="passing-data-to-components"></a>
### Passing Data to Components

You can pass data to RBlade components using HTML attributes. Hard-coded strings can be passed to the component using simple HTML attribute strings. Ruby expressions and variables should be passed to the component via attributes that use the `:` character as a prefix:

```rblade
<x-alert type="error" :message="message"/>
```

#### Component Properties

You can define a component's data properties using a `@props` directive at the top of the component. You can then reference these properties using local variables within the template:

```rblade
{{-- alert.rblade --}}
@props({type: "warning", message: _required})
<div class="{{ type }}">{{ message }}</div>
```

The `@props` directive accepts a `Hash` where the key is the name of the attribute, and the value is the default value for the property. You can use the special `_required` value to represent a property with no default that must always be defined:

```rblade
{{-- This will give an error because the alert component requires a message propery --}}
<x-alert/>
```

All properties in the `@props` directive are automatically removed from `attributes`. Properties with names that aren't valid Ruby variable names or are Ruby reserved keywords are not created as local variables. However, you can reference them via the `attributes` local variable:

```rblade
@props({"for": _required, "data-value": nil})
<div>{{ attributes[:for] }} {{ attributes[:'data-value'] }}</div>
```

<a name="short-attribute-syntax"></a>
#### Short Attribute Syntax

When passing attributes to components, you may also use a "short attribute" syntax. This is often convenient since attribute names frequently match the variable names they correspond to:

```rblade
{{-- Short attribute syntax... --}}
<x-profile :user_id :name />

{{-- Is equivalent to... --}}
<x-profile :user-id="user_id" :name="name" />
```

<a name="escaping-attribute-rendering"></a>
#### Escaping Attribute Rendering

Since some JavaScript frameworks such as Alpine.js also use colon-prefixed attributes, you may use a double colon (`::`) prefix to inform RBlade that the attribute is not a Ruby expression. For example, given the following component:

```rblade
<x-button ::class="{ danger: isDeleting }">
    Submit
</x-button>
```

The following HTML will be rendered by RBlade:

```rblade
<button :class="{ danger: isDeleting }">
    Submit
</button>
```

<a name="component-attributes"></a>
### Component Attributes

We've already examined how to pass data attributes to a component; however, sometimes you may need to specify additional HTML attributes, such as `class`, that are not part of the data required for a component to function. Typically, you want to pass these additional attributes down to the root element of the component template. For example, imagine we want to render an `alert` component like so:

```rblade
<x-alert type="error" :message class="mt-4"/>
```

All of the attributes that are not part of the component's constructor will automatically be added to the component's "attribute manager". This attribute manager is automatically made available to the component via the `attributes` variable. All of the attributes may be rendered within the component by printing this variable:

```rblade
<div {{ attributes }}>
    <!-- Component content -->
</div>
```

<a name="default-and-merged-attributes"></a>
#### Default & Merged Attributes

Sometimes you may need to specify default values for attributes or merge additional values into some of the component's attributes. To accomplish this, you may use the attribute manager's `merge` method. This method is particularly useful for defining a set of default CSS classes that should always be applied to a component:

```rblade
<div {{ attributes.merge({"class": "alert alert-#{type}"}) }}>
    {{ message }}
</div>
```

If we assume this component is utilized like so:

```rblade
<x-alert type="error" :message class="mb-4"/>
```

The final, rendered HTML of the component will appear like the following:

```rblade
<div class="alert alert-error mb-4">
    <!-- Contents of the message variable -->
</div>
```

Both the `class` and `style` attributes are combined this way when using the `attributes.merge` method.

<a name="non-class-attribute-merging"></a>
#### Non-Class Attribute Merging

When merging attributes that are not `class` or `style`, the values provided to the `merge` method will be considered the "default" values of the attribute. However, unlike the `class` and `style` attributes, these defaults will be overwritten if the attribute is defined in the component tag. For example:

```rblade
<button {{ attributes.merge({type: "button"}) }}>
    {{ slot }}
</button>
```

To render the button component with a custom `type`, it can be specified when consuming the component. If no type is specified, the `button` type will be used:

```rblade
<x-button type="submit">
    Submit
</x-button>
```

The rendered HTML of the `button` component in this example would be:

```rblade
<button type="submit">
    Submit
</button>
```

<a name="conditionally-merge-classes"></a>
#### Conditionally Merge Classes

Sometimes you may wish to merge classes if a given condition is `true`. You can accomplish this via the `class` method, which accepts a Hash of classes where the array key contains the class or classes you wish to add, while the value is a boolean expression:

```rblade
<div {{ attributes.class({'p-4': true, 'bg-red': hasError}) }}>
    {{ message }}
</div>
```

If you need to merge other attributes onto your component, you can chain the `merge` method onto the `class` method:

```rblade
<button {{ attributes.class({'bg-red': hasError}).merge({type: 'button'}) }}>
    {{ slot }}
</button>
```

> [!NOTE]  
> If you need to conditionally compile classes on other HTML elements that shouldn't receive merged attributes, you can use the [`@class` directive](#conditional-classes).

<a name="filtering-attributes"></a>
#### Retrieving and Filtering Attributes

The attributes manager is a wrapper around the Ruby Hash class. Unless explicitly overwritten, any methods called on the attributes manager will call that same method on the underlying Hash.

You may filter attributes using the `filter` and `slice` methods. These methods call `filter` and `slice` on the underlying Hash and return a new attributes manager with the result.

```rblade
{{ attributes.filter { |k, v| k == 'foo'} }}
{{ attributes.slice :foo }}
```

If you would like to check if an attribute is present on the component, you may use the `has?` method. This method accepts the attribute name as its only argument and returns a boolean indicating whether or not the attribute is present:

```rblade
@if (attributes.has?(:class))
    <div>Class attribute is present</div>
@endif
```

If multiple parameters are passed to the `has?` method, the method will determine if all of the given attributes are present on the component:

```rblade
@if (attributes.has?('name', 'class'))
    <div>All of the attributes are present</div>
@endif
```

The `has_any?` method may be used to determine if any of the given attributes are present on the component:

```rblade
@if (attributes.has_any?('href', ':href', 'v-bind:href'))
    <div>One of the attributes is present</div>
@endif
```

<a name="slots"></a>
### Slots

You will often need to pass additional content to your component via "slots". The default component slot is rendered by printing the `slot` variable. To explore this concept, let's imagine that an `alert` component has the following markup:

```rblade
{{-- /app/views/components/alert.rblade --}}
<div class="alert alert-danger">
    {{ slot }}
</div>
```

We may pass content to the `slot` by injecting content into the component:

```rblade
<x-alert>
    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

Sometimes a component may need to render multiple different slots in different locations within the component. Let's modify our alert component to allow for the injection of a "title" slot:

```rblade
{{-- /app/views/components/alert.rblade --}}
@props({title: _required})
<span class="alert-title">{{ title }}</span>
<div class="alert alert-danger">
    {{ slot }}
</div>
```

You may define the content of the named slot using the `x-slot` tag. Any content not within an explicit `x-slot` tag will be passed to the component in the `slot` variable:

```xml
<x-alert>
    <x-slot:title>
        Server Error
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>
```

The slot object extends the String interface, so you can invoke a slot's `empty?` method to determine if the slot contains content:

```rblade
<span class="alert-title">{{ title }}</span>

<div class="alert alert-danger">
    @if (slot.empty?)
        This is default content if the slot is empty.
    @else
        {{ slot }}
    @endif
</div>
```

<a name="slot-attributes"></a>
#### Slot Attributes

Like RBlade components, you may assign additional [attributes](#component-attributes) to slots such as CSS class names:

```xml
<x-card class="shadow-sm">
    <x-slot:heading class="font-bold">
        Heading
    </x-slot>

    Content

    <x-slot:footer class="text-sm">
        Footer
    </x-slot>
</x-card>
```

To interact with slot attributes, you may access the `attributes` property of the slot's variable. For more information on how to interact with attributes, please consult the documentation on [component attributes](#component-attributes):

```rblade
@props({
    "heading": _required,
    "footer": _required,
})

<div {{ attributes.class('border') }}>
    <h1 {{ heading.attributes.class('text-lg') }}>
        {{ heading }}
    </h1>

    {{ slot }}

    <footer {{ footer.attributes.class('text-gray-700']) }}>
        {{ footer }}
    </footer>
</div>
```

<a name="registering-additional-component-directories"></a>
### Registering Additional Component Directories

If you are building a package that utilizes RBlade components, or want to store your components elsewhere, you will need to manually register your component directory using the `RBlade::ComponentStore.add_path` method:

```ruby
require "rblade/component_store"

# Auto-discover components in the app/components directory
RBlade::ComponentStore.add_path(Rails.root.join("app", "components"))

# Auto-discover components in the app/views/partials directory with the namespace "partial"
RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "partials"), "partial")
```

If multiple directories are registered with the same namespace, RBlade will search for components in all the directories in the order they were registered.

<a name="anonymous-index-components"></a>
### Index Components

Sometimes, when a component is made up of many RBlade templates, you may wish to group the given component's templates within a single directory. For example, imagine an "accordion" component:

```rblade
<x-accordion>
    <x-accordion.item>
        ...
    </x-accordion.item>
</x-accordion>
```

You could make these components with files in separate directories:

```none
/app/views/components/accordion.rblade
/app/views/components/accordion/item.rblade
```

However, when an `index.rblade` template exists in a directory, it will be rendered when referring to that directory. So instead of having to have the "index" component in a separate `app/views/components/accordion.rblade`, we can group the components together:

```none
/app/views/components/accordion/index.rblade
/app/views/components/accordion/item.rblade
```

<a name="forms"></a>
## Forms

### Old Input

The Rails `params` Hash is available in views and components. However, the `@old` directive is a useful shortcut that will output the old input value for a given key:

```rblade
<input type="text" name="email" value="@old('email', user.email)">
```

The first parameter is the name of the previous input, and the second input is the default if the key isn't present in `params`. The previous example is the equivalent of calling `params.fetch`:

```rblade
<input type="text" name="email" value="{{ params.fetch(:email, user.email) }}">
```

<a name="method-field"></a>
### Method Field

Since HTML forms can't make `PUT`, `PATCH`, or `DELETE` requests, you will need to add a hidden `_method` field to spoof these HTTP verbs. The `@method` RBlade directive can create this field for you:

```rblade
<form action="/foo/bar" method="POST">
    @method('PUT')

    ...
</form>
```

Alternatively, you can use the dedicated directives for each method: `@put`, `@patch`, or `@delete`.


<a name="stacks"></a>
## Stacks

RBlade allows you to push to named stacks which can be rendered elsewhere in another component. This can be particularly useful for specifying any JavaScript libraries required by your child views:

```rblade
@push('scripts')
    <script src="/example.js"></script>
@endPush
```

If you would like to `@push` content if a given boolean expression evaluates to `true`, you may use the `@pushif` directive:

```rblade
@pushIf(shouldPush, 'scripts')
    <script src="/example.js"></script>
@endPushIf
```

You may push to a stack as many times as needed. To render the complete stack contents, pass the name of the stack to the `@stack` directive:

```rblade
<head>
    <!-- Head Contents -->

    @stack('scripts')
</head>
```

If you would like to prepend content onto the beginning of a stack, you should use the `@prepend` directive:

```rblade
@push('scripts')
    This will be second...
@endPush

// Later...

@prepend('scripts')
    This will be first...
@endPrepend
```
