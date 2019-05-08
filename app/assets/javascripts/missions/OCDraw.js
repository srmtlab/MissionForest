class OCDraw{
    constructor(tasks){
        this.tasks = tasks;
        this.options = {
            'data' : this.tasks.get_tasks_hierarchy(),
            'pan': true,
            'zoom': true,
            'draggable': true,
            'createNode': function($node, data) {
                $node.append('<div class="add-button">+</div>');

                if(data.level !== 1){
                    $node.append('<div class="delete-button">&times;</div>');
                }

                if (moment().diff(moment(data.created_at), 'weeks') < 1){
                    $node.append('<div class="new-icon">NEW</div>')
                }
            }
        };
    }

    draw(){
        $('#chart-container').orgchart(this.options);

        let urlParams = new URLSearchParams(location.search);
        if(urlParams.has('taskid')){
            let task_id = urlParams.get('taskid');
            $('#' + task_id).addClass("target_task");
        }
    }
}