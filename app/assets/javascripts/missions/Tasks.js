class Tasks {
    constructor(tasks, user_signed_in, user_id){
        this.tasks = tasks;
        this.datetimepickerformat = 'MM/DD/YYYY HH:mm';
        this.user_signed_in = user_signed_in;
        this.user_id = user_id;
        this.oc = null;
        this.selected_task_id = null;
        this.options = {
            'data' : this.tasks,
            'pan': true,
            'zoom': true,
            'draggable': true,
            'createNode': function($node, data) {
                if(this.user_signed_in)
                {
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

        this.oc.$chart.on('nodedrop.orgchart', function(event) {
            setTimeout('tasks.drop_hierarchy()', 100);
        });

        let urlParams = new URLSearchParams(location.search);
        if(urlParams.has('taskid')){
            let task_id = urlParams.get('taskid');
            $('#' + task_id).addClass("target_task");
        }
    }

    drawDetailTask(selected_task_id){
        this.selected_task_id = selected_task_id;
        
        let task = this.get_task(this.selected_task_id);

        $('#DetailTaskID').text(task.id);
        $('#DetailTaskTitle').val(task.name);
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
                TaskParticipants.append('<li><span class="delete_task_participant" data-task_participant_id="' + participant.id + '">&times;</span>' + participant.name + '</li>');
            }
            else{
                TaskParticipants.append('<li>' + participant.name + '</li>');
            }
        }

        $('#DetailTask').modal('show');
        $('#datetimepickerDetailTaskDeadline').datetimepicker(
            {
                format: this.datetimepickerformat,
            }
        );

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

    delete_task(task_id){

        let stack_tasks = [this.tasks];

        delete_task_label:
        while (stack_tasks.length > 0) {
            let task = stack_tasks.pop();

            for(let i=0; i<task.children.length; i++){
                if(task.children[i].id === task_id){
                    task.children.splice(i, 1);
                    break delete_task_label;
                }
                stack_tasks.push(task.children[i]);
            }
        }

        this.oc.init({
            'data': this.tasks
        });
        this.oc.$chart.on('nodedrop.orgchart', function(event) {
            setTimeout(tasks.drop_hierarchy, 100);
        });
    }

    add_task(task){
        let parent_task_id = task.id;
        let parent_task = this.get_task(parent_task_id);

        parent_task.children.push(task);

        this.oc.init({
            'data': this.tasks
        });
        this.oc.$chart.on('nodedrop.orgchart', function(event) {
            setTimeout(tasks.drop_hierarchy, 100);
        });
    }

    update_task(task){
        let task_id = task.id;
        let update_task = this.get_task(task_id);

        if(typeof task != null){
            update_task.name = task.name;
            update_task.description = task.description;
            update_task.deadline_at = task.deadline_at;
            update_task.status = task.status;
            update_task.notify = task.notify;

            this.oc.init({
                'data': this.tasks
            });
            this.oc.$chart.on('nodedrop.orgchart', function(event) {
                setTimeout(tasks.drop_hierarchy, 100);
            });
        }
    }

    get_selected_task_id(){
        return this.selected_task_id;
    }

    change_hierarchy(target_task_id, change_task_id){
        let target_task;
        let stack_tasks = [this.tasks];

        delete_task_label:
        while (stack_tasks.length > 0) {

            let task = stack_tasks.pop();

            for(let i=0; i<task.children.length; i++){
                if(task.children[i].id === target_task_id){
                    target_task = task.children[i];
                    task.children.splice(i, 1);
                    break delete_task_label;
                }
            }
        }

        let parent_task = this.get_task(change_task_id);
        parent_task.children.push(target_task);

        this.oc.init({
            'data': this.tasks
        });
        this.oc.$chart.on('nodedrop.orgchart', function(event) {
            setTimeout(tasks.drop_hierarchy, 100);
        });        
    }

    add_participant(target_task_id, participant){
        let target_task = this.get_task(target_task_id);
        let exist_flag = false;

        for (let target_task_participant of target_task.participants){
            if(target_task_participant.id === participant.id){
                exist_flag = true;
                break;
            }
        }

        if(!exist_flag)
        {
            target_task.participants.push(participant)
        }
    }

    delete_participant(target_task_id, participant_id){
        let target_task = this.get_task(target_task_id);

        for(let i=0; i<target_task.participants.length; i++){
            if(target_task.participants[i].id === participant_id){
                task.children.splice(i, 1);
                break;
            }
        }
    }

    drop_hierarchy(){
        let user_id = this.user_id;
        /*

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
         */
    }
}