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


				if(data['status'] === "init" && typeof tasks === 'undefined')
				{
					tasks = new Tasks(data.tasks, user_signed_in, user_id);
					tasks.draw('#chart-container');
					mission = new Mission(data.mission, user_signed_in, user_id, mission_id)
				}
				else if (data.status === "work" && typeof tasks !== 'undefined')
				{
					let operation = data.operation;
					let type = data.type;
					let fixdata = data.data;

					if(type === "mission")
					{
						if(operation === "update")
						{
							mission.update_mission(fixdata);
						}
						else if(operation === "delete"){
							location.href = "/";
						}
					}
					else if(type === "task")
					{
						if(operation === "add")
						{
							tasks.add_task(fixdata);
						}
						else if(operation === "update")
						{
							tasks.update_task(fixdata);
						}
						else if(operation === "delete")
						{
							tasks.delete_task(fixdata);
						}
					}
					else if(type === "task_participant")
					{
						if(operation === "add")
						{
							tasks.add_participant(fixdata);
						}
						else if(operation === "delete")
						{
							tasks.delete_participant(fixdata);
						}
					}
					else if(type === "mission_participant")
					{
						if(operation === "add")
						{
							if(fixdata.id === user_id){
								location.reload();
							}
							else {
								mission.add_participant(fixdata);
							}
						}
						else if(operation === "delete")
						{
							if(fixdata.id === user_id){
								location.reload();
							}
							else {
								mission.delete_participant(fixdata);
							}
						}
					}
					else if(type === "mission_admin")
					{
						if(operation === "add")
						{
							if(fixdata.id === user_id){
								location.reload();
							}else {
								mission.add_admin(fixdata);
							}

						}
						else if(operation === "delete")
						{
							if(fixdata.id === user_id){
								location.reload();
							}else {
								mission.delete_admin(fixdata)
							}

						}
					}
				}
			},

			send_add_task: function(task){
				return this.perform('add_task', task)
			},

			send_update_task : function(task){
				return this.perform('update_task', task)
			},

			send_delete_task: function(task){
				return this.perform('delete_task', task)
			},

			send_update_mission: function(mission){
				return this.perform('update_mission', mission)
			},

			send_delete_mission: function(mission){
				return this.perform('delete_mission', mission)
			},


			send_add_task_participant: function(participant){
				return this.perform('add_task_participant', participant)
			},

			send_delete_task_participant: function(participant){
				return this.perform('delete_task_participant', participant)
			},


			send_add_mission_participant: function(participant){
				return this.perform('add_mission_participant', participant)
			},

			send_delete_mission_participant: function(participant){
				return this.perform('delete_mission_participant', participant)
			},

			send_add_mission_admin: function(admin){
				return this.perform('add_mission_admin', admin)
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
