# Data folder README

This is the "data" folder. This is where you can define the data to use in your templates.

## Defining data

Put some `.yml`, `.csv`, or `.sh` files in this folder to make the data in the files available to your templates.

For example, in `products.yml` we have:

```yaml
product1
  name: My Cool Product ONE
  price: 100
product2
  name: My Cooler Product TWO
  price: 220
```

In `people.csv`, we have:

```csv
id,name,age
1,Bob,56
2,Jane,45
```

You can also define the data in a `.sh` script containing Bash variables & arrays. See `arrays-example.sh`

## Accessing data

There are various ways to access the data in your templates.

### Directly

You can access _variable names_ in your templates like so:

```handlebars
{{page_title}}
```

You can access _indexed arrays_ in your templates like so:

```handlebars
{{#someArray}}
  {{.}}
{{/someArray}}
```

To access more complex data like associative arrays (hashes), nested objects, CSV, etc, see below.

### The `foreach` method

You can access your data objects and arrays with the `foreach` iterator.

Example:

Accessing our `products.yml` data:

```handlebars
{{#foreach product in products}}
  Name:  {{product.name}}
  Price: {{product.price}}
{{/foreach}}
```

Accessing our `people.csv` data:

```handlebars
{{#foreach person in people}}
  {{person.name}} is {{person.age}} years old.
{{/foreach}}
```

### The `lookup` method

You can also access specific data values in your templates using a handlebars-style `lookup` method.

The `lookup` method takes one parameter, a JavaScript-style, dot-notation data object, and returns the corresponding data.

Example:

Accessing our `products.yml` data:

```handlebars
{{lookup products.product1.name}}
```

Accessing our `people.csv` data:

```handlebars
{{lookup people[0].name}}
```
