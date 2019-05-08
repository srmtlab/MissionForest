class TaskDatabase {
    constructor(task_data){
        this.hierarchy = task_data.hierarchy;
        this.all_tasks = task_data.all_tasks;
    }


    get_task_detail(search_task_id){
        for (let task of this.get_all_tasks()){
            if(task.id === search_task_id){
                return task;
            }
        }
        return null;
    }


    update_task_detail(task_id, title, description,
                       deadline_at, status, notify){
        let task_detail = this.get_task_detail(task_id);
        task_detail.title = title != null ? title : task_detail.title;
        task_detail.description = description != null ? description : task_detail.description;
        task_detail.deadline_at = deadline_at != null ? deadline_at : task_detail.deadline_at;
        task_detail.status = status != null ? status : task_detail.status;
        task_detail.notify = notify != null ? notify : task_detail.notify;


        console.log(task_detail);
        $.ajax({
            type: 'PUT',
            url: '/api/tasks/' + task_id + '/update',
            data: {
                task: {
                    title: task_detail.title,
                    description: task_detail.description,
                    deadline_at: task_detail.deadline_at,
                    status: task_detail.status,
                    notify: task_detail.notify
                }
            },
            success: function(data) {
                console.log(data);
                tasks.update_hierarchy(data.task_data.hierarchy);
                tasks.update_all_tasks(data.task_data.all_tasks);

                oc.init({'data': data.task_data.hierarchy});
                oc.$chart.on('nodedrop.orgchart', function(event) {
                    console.log('drop');
                    setTimeout('tasks.drop_hierarchy()', 100);
                });
            }
        })
    }

    add_new_task(parent_task_id, title, description,
                 deadline_at, status, notify){
        let task_detail = {};

        task_detail.title = title;
        task_detail.description = description;
        task_detail.deadline_at = deadline_at;
        task_detail.status = status;
        task_detail.notify = notify;
        task_detail.mission_id = mission_id;
        task_detail.sub_task_of = parent_task_id;
        //task_detail.user_id = <= current_user.id >;

        $.ajax({
            type: 'POST',
            url: '/api/missions/<%= @mission.id %>/task',
            data: {
                task: {
                    title: task_detail.title,
                    description: task_detail.description,
                    sub_task_of: task_detail.sub_task_of,
                    deadline_at: task_detail.deadline_at,
                    status: task_detail.status,
                    notify: task_detail.notify
                }
            },
            success: function(data) {
                tasks.update_hierarchy(data.task_data.hierarchy);
                tasks.update_all_tasks(data.task_data.all_tasks);

                console.log(tasks.get_all_tasks());

                oc.init({'data': data.task_data.hierarchy});
                oc.$chart.on('nodedrop.orgchart', function(event) {
                    console.log('drop');
                    setTimeout('tasks.drop_hierarchy()', 100);
                });
            }
        })
    }

    delete_task(task_id){
        $.ajax({
            type: 'DELETE',
            url: '/api/tasks/' + task_id + '/delete',
            data: {
                'id' : task_id
            },
            success: function(data) {
                tasks.update_hierarchy(data.task_data.hierarchy);
                tasks.update_all_tasks(data.task_data.all_tasks);

                oc.init({'data': data.task_data.hierarchy});
                oc.$chart.on('nodedrop.orgchart', function(event) {
                    console.log('drop');
                    setTimeout('tasks.drop_hierarchy()', 100);
                });
            }
        })
    }

    participate_to_task(task_id){
        $.ajax({
            type: 'PUT',
            url: '/api/tasks/' + task_id + '/add_participant',
            data: {
                'id' : task_id,
                'user_id' : user_id
            },
            success: function(data) {
                tasks.update_hierarchy(data.task_data.hierarchy);
                tasks.update_all_tasks(data.task_data.all_tasks);

                oc.init({'data': data.task_data.hierarchy});
                oc.$chart.on('nodedrop.orgchart', function(event) {
                    console.log('drop');
                    setTimeout('tasks.drop_hierarchy()', 100);
                });
            }
        })
    }


    get_tasks_hierarchy(){
        return this.hierarchy;
    }

    get_all_tasks(){
        return this.all_tasks;
    }

    set_selected_task_id(task_id){
        this.selected_id = task_id
    }

    get_selected_task_id(){
        return this.selected_id;
    }

    update_hierarchy(hierarchy){
        this.hierarchy = hierarchy;
    }

    update_all_tasks(all_tasks){
        this.all_tasks = all_tasks;
    }


    drop_hierarchy(){
        let taskdb = this;
        let user_id = <%= current_user.id %>;

        function recursion(tree, taskdb){
            const id = tree['id'];
            const detail = taskdb.get_task_detail(id);
            tree['name'] = detail['title'];

            if (tree['children'] === undefined){
                return;
            }
            for (let child of tree['children']){
                recursion(child, taskdb);
            }
        }

        let hierarchy = oc.getHierarchy();
        recursion(hierarchy, taskdb);

        $.ajax({
            type: 'PUT',
            url: '/api/missions/<%= @mission.id %>/update_hierarchy',
            data: {
                tree : hierarchy,
                user_id : user_id
            }
        });

        App.mission.change_tasktree(hierarchy);
    }
}