$(function(){
		const channel = 'MissionChannel'
		const mission_id = $('#mission_id').text()
		
		
		App.mission = App.cable.subscriptions.create(
				{
						channel:channel,
						mission_id:mission_id
				},
				{
						connected: function() {
								// Called when the subscription is ready for use on the server
						},
						
						disconnected: function() {
								// Called when the subscription has been terminated by the server
						},
						
						received: function(data) {
								// Called when there's incoming data on the websocket for this channel
								console.log(data)
								tasks.update_hierarchy(data)
								oc.init({'data':tasks.get_tasks_hierarchy()})
						},
						
						change_tasktree: function(tree){
								return this.perform('change_tasktree', { tree:tree })
						}
				});
});
