<md-table>
	<yield />

	<input if="{ opts.search }"
		type="text" onkeyup="{ onKeyup }">

	<table name="el" class="md-table">
		<thead>
			<tr name="labels">
				<th each="{ c in tags['md-table-col'] }" onclick="{ sortTable }"
					data-order="{ c.opts.order || 'asc' }"
					data-key="{ c.opts.key }" style="width: { c.opts.width || 'auto' }">
					{ c.opts.label } <i></i>
				</th>
			</tr>
		</thead>

		<tbody name="tbody"></tbody>
	</table>

	<script>
		var self = this,
			doc = document,
			rowClick = opts.onclick,
			_selected = 'tr__selected';

		self.cols = []; // the `thead th` elements
		self.rows = []; // the `tbody tr` elements
		self.keys = []; // the datakeys per column
		self.widths = {}; // the widths per column
		self.builders = {}; // cols render methods
		self.sorters = {}; // cols sorting methods
		self.selected = null; // selected row item

		/**
		 * Draw all table rows within `opts.data`
		 */
		self.drawRows = function () {
			console.time('first draw');
			self.rows = [];
			opts.data.forEach(function (row, i) {
				var item = self.drawRow(row, i)
				self.rows.push(item);
				self.tbody.appendChild(item);
			});
			console.timeEnd('first draw');
		};

		/**
		 * Draw a single row
		 * @param  {Array} data   The row's data object
		 * @param  {Integer} idx  The row's index within `opts.data`
		 * @return {Node}         The constructed row
		 */
		self.drawRow = function (data, idx) {
			var tr = doc.createElement('tr');
			tr.id = data.id || 'tr-' + idx;

			// mock-up riot's e.item object (since no dom-loop)
			tr.onclick = function (e) {
				e.item = this;
				self.onRowClick(e);
			};

			drawCells(tr, data);

			// send back the full `<tr>` row
			return tr;
		};

		/**
		 * Build & Attach `<td>` nodes to a `<tr>`
		 * @param  {Node}   tr
		 * @param  {Object} data   The row's data object
		 */
		function drawCells(tr, data) {
			// loop thru keys
			self.keys.forEach(function (key) {
				var td = doc.createElement('td');
				td.width = self.widths[key];

				// check if this cell should be mutated
				var builder = buildCell(key, data);

				// table looks @ this & will use for sorter
				td.value = builder.isMutated ? data[key] : builder.value;
				td.innerHTML = '<div class="td__inner">'+ builder.value +'</div>';

				// add this `<td>` to the `<tr>`
				tr.appendChild(td);
			});
		}

		/**
		 * Determine a single cell's value
		 * @param  {String} key  The cell col's key name
		 * @param  {Object} data The row's data object
		 * @return {Object}      The cell's computed values
		 */
		function buildCell(key, data) {
			var val, isMutated = false;

			if (self.builders[key]) {
				val = self.builders[key](data);
				isMutated = true;
			} else {
				val = data[key];
			}

			return {isMutated: isMutated, value: val};
		}

		/**
		 * Assign a `click` handler to each row
		 * - Func is passed in via `tr.onclick`
		 */
		self.onRowClick = function (e) {
			if (self.selected) {
				classie.remove(self.selected, _selected);
			}

			classie.add(e.item, _selected);
			self.selected = e.item;

			if (rowClick) {
				rowClick(e.item);
			}
		};

		self.onKeyup = debounce(function (e) {
			self.searchTable(e.target.value);
		}, 250);

		/**
		 * Use the Search's value to hide non-matching rows
		 * @param  {String} val   The search input's value
		 */
		self.searchTable = function (val) {
			console.log('inside');
			var rgx = new RegExp(val, 'i');
			// test each cell by what's displaying (not always original value)
			[].forEach.call(self.tbody.getElementsByTagName('td'), function (td) {
				td.parentNode.style.display = rgx.test(td.innerText) ? 'table-row' : 'none';
			});
		};

		/**
		 * Sort the Table rows by `<th>`s `data-key`
		 * @param  {Event} e
		 */
		self.sortTable = function (e) {
			var th = e.target,
				key = th.getAttribute('data-key'),
				sorter = self.sorters[key];

			// no `data-key` or sorter method? do nothing
			if (!key || !sorter) {
				return;
			}

			var sorted = th.getAttribute('data-sort'),
				// if there's already a `sorted`, do opposite, else default to `asc`
				order = sorted ? ((sorted === 'asc') ? 'desc' : 'asc') : th.getAttribute('data-order');
			console.log('new order: ', order);

			// "asynchronously" sort the table; frees up main thread a bit
			return setTimeout(function () {
				handleSort(th, order, sorter);
			}, 1);
		};

		/**
		 * Perform the sorting function
		 * @param  {Node} th           The clicked `<th>` element
		 * @param  {String} order      The sorting direction, 'asc|desc'
		 * @param  {Function} sorter   The column's sorting function
		 */
		function handleSort(th, order, sorter) {
			console.time('handleSort');
			var idx = th.cellIndex;

			// Extract each row's `key` value && pair it with its `<tr>` as a tuple.
			// This way sorting the values will incidentally sort the body rows.
			var column = self.rows.map(function (tr, i) {
				return [tr.children[idx].value, tr];
			});

			// Sort by the column's `key` value
			column.sort(function (a, b) {
				return sorter(a[0], b[0]);
			});

			// Reverse sorted array if not `asc`, which was assumed
			if (order === 'desc') {
				column.reverse();
			}

			// Replace `self.rows` with the sorted rows.
			self.rows = column.map(function (tup) {
				return tup[1]; // `<tr>` is 2nd item of tuple
			});

			// Write to `<tbody` without duplicating
			console.time('re-append');
			self.rows.forEach(function (el) {
				self.tbody.appendChild(el);
			});
			console.timeEnd('re-append');

			// Reset all `<th>`s except current
			self.cols.forEach(function (el, i) {
				if (i === self.actionsCol) {
					return;
				}
				if (el === th) {
					el.setAttribute('data-sort', order);
				} else {
					el.removeAttribute('data-sort');
				}
			});
			console.timeEnd('handleSort');
		}

		/**
		 * On Init, Prepare & Collect `md-table-col` stats
		 */
		self.on('mount', function () {
			self.cols = [].slice.call(self.labels.children); // get `<th>` after loop runs

			// save the columns' datakeys & widths. will be used for `<td>` childs
			self.tags['md-table-col'].forEach(function (c) {
				var k = c.opts.key;

				self.keys.push(k);
				self.widths[k] = c.opts.width || 'auto';

				// has a custom renderer?
				self.builders[k] = c.opts.render || false;
				// has a sorter method?
				self.sorters[k] = c.opts.sorter || false;

				// remove the `<md-table-col>` tags from DOM, useless now
				self.root.removeChild(c.root);
			});

			// check if there's an Actions column
			if (opts.actions) {
				self.actionsCol = parseInt(opts.actions);
			}

			console.info('mount sending `update`');
			self.update();
		});

		/**
		 * On `update`, draw the tablerows if has new data
		 */
		self.on('update', function () {
			console.warn('inside `md-table` update');
			if (self.keys.length && opts.data.length > self.rows.length) {
				self.drawRows();
			}
		});
	</script>

	<style>
		@import "md-table.sass";
	</style>
</md-table>
