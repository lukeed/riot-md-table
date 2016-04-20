riot.tag2('md-table', '<yield></yield> <input if="{opts.search}" type="text" onkeyup="{onKeyup}"> <table name="el" class="md-table"> <thead> <tr name="labels"> <th each="{c in tags[\'md-table-col\']}" onclick="{sortTable}" data-order="{c.opts.order || \'asc\'}" data-key="{c.opts.key}" riot-style="width: {c.opts.width || \'auto\'}"> {c.opts.label} <i></i> </th> </tr> </thead> <tbody name="tbody"></tbody> </table>', ':scope p { color: #2196f3; }', '', function(opts) {
		var self = this,
			doc = document,
			rowClick = opts.onclick,
			_selected = 'tr__selected';

		self.cols = [];
		self.rows = [];
		self.keys = [];
		self.widths = {};
		self.builders = {};
		self.sorters = {};
		self.selected = null;

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

		self.drawRow = function (data, idx) {
			var tr = doc.createElement('tr');
			tr.id = data.id || 'tr-' + idx;

			tr.onclick = function (e) {
				e.item = this;
				self.onRowClick(e);
			};

			drawCells(tr, data);

			return tr;
		};

		function drawCells(tr, data) {

			self.keys.forEach(function (key) {
				var td = doc.createElement('td');
				td.width = self.widths[key];

				var builder = buildCell(key, data);

				td.value = builder.isMutated ? data[key] : builder.value;
				td.innerHTML = '<div class="td__inner">'+ builder.value +'</div>';

				tr.appendChild(td);
			});
		}

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

		self.searchTable = function (val) {
			console.log('inside');
			var rgx = new RegExp(val, 'i');

			[].forEach.call(self.tbody.getElementsByTagName('td'), function (td) {
				td.parentNode.style.display = rgx.test(td.innerText) ? 'table-row' : 'none';
			});
		};

		self.sortTable = function (e) {
			var th = e.target,
				key = th.getAttribute('data-key'),
				sorter = self.sorters[key];

			if (!key || !sorter) {
				return;
			}

			var sorted = th.getAttribute('data-sort'),

				order = sorted ? ((sorted === 'asc') ? 'desc' : 'asc') : th.getAttribute('data-order');
			console.log('new order: ', order);

			return setTimeout(function () {
				handleSort(th, order, sorter);
			}, 1);
		};

		function handleSort(th, order, sorter) {
			console.time('handleSort');
			var idx = th.cellIndex;

			var column = self.rows.map(function (tr, i) {
				return [tr.children[idx].value, tr];
			});

			column.sort(function (a, b) {
				return sorter(a[0], b[0]);
			});

			if (order === 'desc') {
				column.reverse();
			}

			self.rows = column.map(function (tup) {
				return tup[1];
			});

			console.time('re-append');
			self.rows.forEach(function (el) {
				self.tbody.appendChild(el);
			});
			console.timeEnd('re-append');

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

		self.on('mount', function () {
			self.cols = [].slice.call(self.labels.children);

			self.tags['md-table-col'].forEach(function (c) {
				var k = c.opts.key;

				self.keys.push(k);
				self.widths[k] = c.opts.width || 'auto';

				self.builders[k] = c.opts.render || false;

				self.sorters[k] = c.opts.sorter || false;

				self.root.removeChild(c.root);
			});

			if (opts.actions) {
				self.actionsCol = parseInt(opts.actions);
			}

			console.info('mount sending `update`');
			self.update();
		});

		self.on('update', function () {
			console.warn('inside `md-table` update');
			if (self.keys.length && opts.data.length > self.rows.length) {
				self.drawRows();
			}
		});
});
