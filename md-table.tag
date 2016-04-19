<md-table>
	<p onclick="{ onClick }">Hallo hallo!</p>

	<script>
		console.log('before `mount` event: ', this.root);

		onClick(e) {
			alert('clicked!');
		}

		this.on('mount', function () {
			console.log('mounted');
		}.bind(this));
	</script>

	<style scoped>
		@import "md-table.sass";
	</style>
</md-table>
