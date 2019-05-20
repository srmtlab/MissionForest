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
                return this.perform('init')
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
					else if(type === "mission_participant")
					{
						if(operation === "add")
						{
							add_node(data);
						}
						else if(operation === "delete")
						{
							delete_node(data)
						}
					}
					else if(type === "mission_admin")
					{
						if(operation === "add")
						{
							add_node(data);
						}
						else if(operation === "delete")
						{
							delete_node(data)
						}
					}
                    else if(type === "task_participant")
                    {
                        if(operation === "add")
                        {
                            add_node(data);
                        }
                        else if(operation === "delete")
                        {
                            delete_node(data)
                        }
                    }
				}
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

			send_add_task_participant: function(participant){
				return this.perform('add_task_participant', participant)
			},

            send_delete_task_participant: function(participant){
                return this.perform('delete_task_participant', participant)
            },

            send_delete_mission_participant: function(participant){
                return this.perform('delete_mission_participant', participant)
            },

            send_delete_mission_admin: function(admin){
                return this.perform('delete_mission_admin', admin)
            },

			change_tasktree: function(tree){
				return this.perform('change_tasktree', { 
					tree:tree 
				})
			}
		});
});
