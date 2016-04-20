<md-table-filters>
  <div each="{ filter in opts.filters }" class="dropdown">
  	<button class="btn dropdown--toggle">{ filter.label }</button>
  </div>

  <script>
    this.select = function (e) {
    	console.log('selected!', e.target);
    };
  </script>
</md-table-filters>
