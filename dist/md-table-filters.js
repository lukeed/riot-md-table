riot.tag2('md-table-filters', '<div each="{filter in opts.filters}" class="dropdown"> <button class="btn dropdown--toggle">{filter.label}</button> </div>', '', '', function(opts) {
    this.select = function (e) {
    	console.log('selected!', e.target);
    };
});
