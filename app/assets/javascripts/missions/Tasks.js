class Tasks {
    constructor(tasks, user_signed_in, user_id){
        this.tasks = tasks;
        this.datetimepickerformat = 'MM/DD/YYYY HH:mm';
        this.user_signed_in = user_signed_in;
        this.user_id = user_id;
        this.oc = null;
        this.selected_task_id = null;
        this.options = {
            'data' : this.tasks.get_tasks_hierarchy(),
            'pan': true,
            'zoom': true,
            'draggable': true,
            'createNode': function($node, data) {
                if(this.user_signed_in){
                    $node.append('<div class="add-button">+</div>');

                    if(data.level !== 1){
                        $node.append('<div class="delete-button">&times;</div>');
                    }
                }

                if (moment().diff(moment(data.created_at), 'weeks') < 1){
                    $node.append('<div class="new-icon">NEW</div>')
                }
            }
        };

    }

    get_task(search_task_id){
        let stack_tasks = [this.tasks];

        while (stack_tasks.length > 0) {
            let task = stack_tasks.pop();
            if (task.id === search_task_id){
                return task;
            }

            for(let child_task of task.children){
                stack_tasks.push(child_task);
            }
        }
        return null;
    }

    draw(container_id){
        this.oc = $(container_id).orgchart(this.options);

        let urlParams = new URLSearchParams(location.search);
        if(urlParams.has('taskid')){
            let task_id = urlParams.get('taskid');
            $('#' + task_id).addClass("target_task");
        }
    }

    drawDetailTask(selected_task_id){
        this.selected_task_id = selected_task_id;
        
        $('#DetailTask').modal('show');
        $('#datetimepickerDetailTaskDeadline').datetimepicker(
            {
                format: this.datetimepickerformat,
            }
        );
        let task = this.get_task(this.selected_task_id);

        $('#DetailTaskID').text(task.id);
        $('#DetailTaskTitle').val(task.title);
        $('#DetailTaskDescription').val(task.description);

        let deadline = task.deadline_at;
        if(deadline !== null){
            $('#DetailTaskDeadline').val(moment(deadline).format(this.datetimepickerformat));
        }
        $('#DetailTaskStatus').val(task.status);
        $('#DetailTaskNotify').val(task.notify);
        if (task.notify === 'lod'){
            $('.ccby-license').addClass('ccby-active');
        }
        else {
            $('.ccby-license').removeClass('ccby-active');
        }

        let TaskParticipants = $('#TaskParticipants');
        TaskParticipants.empty();
        for (let participant of task.participants){
            if(this.user_signed_in && participant.id === user_id){
                TaskParticipants.append('<li><span class="delete_task_participant" participant_id="' + participant.id + '">&times;</span>' + participant.name + '</li>');
            }
            else{
                TaskParticipants.append('<li>' + participant.name + '</li>');
            }
        }

        if(lod){
            $('#TaskTags').empty();
            let task_id = this.selected_task_id;
            let query =
                'PREFIX mf-task: <http://lod.srmt.nitech.ac.jp/resource/MissionForest/tasks/>'
                + 'PREFIX tags: <http://lod.srmt.nitech.ac.jp/tags/ontology#>'
                + ''
                + 'select ?tags where{'
                + '  ?annotate tags:target mf-task:' + task_id + ' ;'
                + '  tags:body ?tags.'
                + '}';
    
            $.ajax({
                type: 'GET',
                url: sparql_endpoint,
                data: {
                    'query' : query,
                    'format' : 'application/sparql-results+json',
                    'default-graph-uri' : lod_graph_uri
                },
                success: function(data) {
                    console.log(data);
                    for ( let x of data['results']['bindings'] ){
                        let tag_name = x['tags']['value'];
                        $('#TaskTags').append('<li><a href="' + tag_name + '">' + tag_name + '</a></li>');
                    }
                }
            });
        }
    }

    drawAddTask(selected_task_id){
        this.selected_task_id = selected_task_id;
        $('#AddTask').modal('show');
        $('#datetimepickerAddTaskDeadline').datetimepicker(
            {
                format: this.datetimepickerformat,
            }
        );
        $('#AddTaskTitle').val('');
        $('#AddTaskDescription').val('')
    }

    drawDeleteTask(selected_task_id){
        this.selected_task_id = selected_task_id;

        let task = this.get_task(this.selected_task_id);

        $('#ConfirmDelete').modal('show');
        $('#DeleteTaskID').val(task.id);
        $('#DeleteTaskTitle').text(task.title);
    }

    /*=========================================================================================*/
    update_task_detail(task_id, title, description,
                       deadline_at, status, notify){
        let task_detail = this.get_task_detail(task_id);
        if(task_detail !== null){
            task_detail.title = title != null ? title : task_detail.title;
            task_detail.description = description != null ? description : task_detail.description;
            task_detail.deadline_at = deadline_at != null ? deadline_at : task_detail.deadline_at;
            task_detail.status = status != null ? status : task_detail.status;
            task_detail.notify = notify != null ? notify : task_detail.notify;
        }

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