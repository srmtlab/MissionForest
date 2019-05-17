$(function(){
	const channel = 'MissionChannel';

	App.mission = App.cable.subscriptions.create(
		{
			channel:channel,
			mission_id:mission_id
		},
		{
			connected: function() {
				// Called when the subscription is ready for use on the server
                return this.perform('init', { 'status': 'init' })

			},

			disconnected: function() {
				// Called when the subscription has been terminated by the server
			},

			received: function(data) {
				// Called when there's incoming data on the websocket for this channel
				if(data.status === "init" && typeof tasks === 'undefined')
				{
					tasks = new Tasks(data.tasks, user_signed_in, user_id);
					tasks.draw('#chart-container');
				}
				else if (data.status === "work" && typeof tasks !== 'undefined')
				{
					let operation = data.operation;
					let type = data.type;
					let data = data.data;

					if(type === "mission")
					{
						if(operation === "edit")
						{
							$('#mission-title').text(data.title);
							$('#mission-description').text(data.description);
						}
					}
					else if(type === "task")
					{
						if(operation === "add")
						{
							add_node(data);
						}
						else if(operation === "delete")
						{
							delete_node(data)
						}
						else if(operation === "edit")
						{
							edit_node(data)
						}
					}
				}

				tasks.update_hierarchy(data);
				oc.init({'data':tasks.get_tasks_hierarchy()});

				oc.$chart.on('nodedrop.orgchart', function(event) {
					console.log('drop');
					setTimeout('tasks.drop_hierarchy()', 100);
				});
			},

			send_delete_task: function(task){
				return this.perform('delete_task', task)
			},

			send_update_task : function(task){
				return this.perform('update_task', task)
			},

			send_add_task: function(task){
				return this.perform('add_task', task)
			},

			change_tasktree: function(tree){
				return this.perform('change_tasktree', { 
					tree:tree 
				})
			}
		});
});
