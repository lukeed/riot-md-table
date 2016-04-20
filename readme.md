# riot-md-table
> Material Design table component, for Riot.js

#### Work In Progress / Incomplete

## Installation

```bash
bower install riot-md-table
```

or

```bash
npm install riot-md-table
```

## Usage

```html
<md-table data="{ data }" actions="4" onclick="{ onClick }">
	<md-table-col label="Col1" key="key1" order="desc" />
	<md-table-col label="Col2" key="key2" />
	<md-table-col label="Col3" key="key3" render="{ toDollars }" />
	<md-table-col label="Col4" key="key4" sorter="{ string }" />
	<md-table-col label="Actions" />
</md-table>

this.data = [
	{ id: "id1", key1: "val1", key2: "val2", key3: "val3", key4: "val4" },
	{ id: "id2", key1: "val1", key2: "val2", key3: "val3", key4: "val4" },
	{ key1: "val1", key2: "val2", key3: "val3", key4: "val4" },
	{ key1: "val1", key2: "val2", key3: "val3", key4: "val4" }
]

this.string = function (a, b) {
	return a.localeStringCompare(b);
}

this.toDollars = function (val) {
	return '$' + val;
}

this.onClick = function (e) {
	console.log('extra `click` listener for each row: ', e.item);
}
```

## Options

### For `md-table`

#### data

> Type: `Array` <br>
> Default: `[]` <br>
> Required: `true`

Table's data, an `Array` of `Object`s.

Each `data` Object should be the `key:value` pairs for a single row. These `key` names are used by `md-table-col` tags to select a data value.

An optional `id` key may be used to set the `id` attribute of the `<tr>` element.

##### data[ Object.id ]

> Type: `Mixed` <br>
> Default: `tr-{ index }` <br>
> Required: `false`

If not set, the data object's index (within all of `data`) becomes the row's id: `tr-{index}`.

```js
this.data = [
	{name: 'John', age: 32, job: 'Worker Bee'},
	{id: 'queen', name: 'Sally', age: 26, job: 'Queen Bee'}
	{name: 'Jack', age: 19, job: 'Worker Bee'},
];
```

```html
<tbody>
	<tr id="tr-0">
		<td>John</td>
		<td>32</td>
		<td>Worker Bee</td>
	</tr>
	<tr id="queen">
		<td>Sally</td>
		<td>26</td>
		<td>Queen Bee</td>
	</tr>
	<tr id="tr-2">
		<td>Jack</td>
		<td>19</td>
		<td>Worker Bee</td>
	</tr>
</tbody>
```

#### actions

> Type: `Integer` <br>
> Default: `null` <br>
> Required: `false`

If table has an "Actions" column (does not contain data), pass its column index here. 0 based.

#### onclick

> Type: `Function` <br>
> Default: `null` <br>
> Required: `false`

Event handler for every `<td>` or `<tr>` within `<tbody>`. The event's `event.item` value will **always** be a `<tr>` node, even if a child cell triggered the `click`.

### For `md-table-col`

#### label

> Type: `String` <br>
> Required: `true`

The column's title.

#### width

> Type: `String` <br>
> Default: `auto` <br>
> Required: `false`

The column's width. Pixel or percentage widths are allowed.

#### key

> Type: `String` <br>
> Required: `sometimes`

The `key` corresponds to a `data` object key. **Required if** the column is meant to display data.

#### order

> Type: `String` <br>
> Default: `asc` <br>
> Options: `asc` or `desc` <br>
> Required: `false`

The first direction when sorting. 

For example, if `desc`, the first click on `<th>` will sort the column values in _descending_ order. The second click will sort the values in _ascending_ order.

#### render

> Type: `Function` <br>
> Required: `false`

A custom function to manipulate the cell's original value. Useful for applying prefixes or suffixes to values.

The cell's original value will **always** be assigned as `value` to the `<td>` element, even if a `render` method is used.

```html
<md-table>
  <md-table-col label="Value" render="{ toDollars }" />
</md-table>
<!-- method prepends all values with a '$' and appends '.00' -->
this.toDollars = function (val) {
	return '$' + val + '.00';
}
```

After `mount`:

```html
<td width="auto">
	<div class="td__inner">$100.00</div>
</td>
```

```js
console.log(td.value); // 100
```

#### sorter

> Type: `Function` <br>
> Required: `false`

The sorting function used to arrange a column by its values. **If not set** then no sorting will occur when `<th>` is clicked.

## License

MIT © [Luke Edwards](https://lukeed.com)
