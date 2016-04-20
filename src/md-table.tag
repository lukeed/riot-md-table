<md-table>
	<yield />

	<table name="el" class="md-table">
		<thead>
			<tr name="labels">
				<th each="{ c in tags['md-table-col'] }" onclick="{ sortTable }"
					data-key="{ c.opts.key }" data-order="{ c.opts.order || 'asc' }"
					style="width: { c.opts.width || 'auto' }">
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
		self.builders = {}; // cols renderer funcs
		self.selected = null; // selected row item

		/**
		 * Draw all table rows within `opts.data`
		 */
		self.drawRows = function () {
			console.info('inside drawRows');
			self.rows = [];
			opts.data.forEach(function (row, i) {
				var item = self.drawRow(row, i)
				self.rows.push(item);
				self.tbody.appendChild(item);
			});
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

		function drawCells(tr, data) {
			// loop thru keys
			self.keys.forEach(function (key) {
				var td = doc.createElement('td');
				td.width = self.widths[key];

				// check if this cell should be mutated
				var builder = buildCell(key, data);

				// table looks @ this & will use for sorter, if set
				if (builder.isMutated) {
					td.setAttribute('data-sort-value', data[key]);
				}

				td.innerHTML = '<div class="td__inner">'+ builder.value +'</div>';

				// add this `<td>` to the `<tr>`
				tr.appendChild(td);
			});
		}

		function buildCell(key, data) {
			var val, isMutated = false;

			if (self.builders[key]) {
				val = builders[key](data);
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

			if (rowClick) {
				rowClick(e.item.id);
			}
		};

		self.sortTable = function (e) {
			var th = e.target,
				idx = th.cellIndex,
				type = th.getAttribute('data-sort');

			console.log('inside sortTable');
		};

		self.on('mount', function () {
			self.cols = [].slice.call(self.labels.children); // get `<th>` after loop runs

			// save the columns' datakeys & widths. will be used for `<td>` childs
			self.tags['md-table-col'].forEach(function (c) {
				var k = c.opts.key;
				self.keys.push(k);
				self.widths[k] = c.opts.width || 'auto';
				if (c.opts.render) {
					self.builders[k] = c.opts.render;
				}
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
