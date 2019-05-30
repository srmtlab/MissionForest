class Mission {
    constructor(mission, user_signed_in, user_id, mission_id){
        this.mission = mission;
        this.user_signed_in = user_signed_in;
        this.user_id = user_id;
        this.mission_id = mission_id;
    }

    drawDeleteMissionParticipant(){
        $('#DeleteMissionParticipantTitle').text(this.mission['name']);
        $('#ConfirmDeleteMissionParticipant').modal('show');
    }

    drawDetailMissionParticipants(){
        let mission = this.mission;
        let MissionParticipantsTB = $('#MissionParticipantsTB');
        MissionParticipantsTB.empty();

        for(let participant_id in mission['participants']){
            if(mission['participants'].hasOwnProperty(participant_id)){
                if(mission['admins'].hasOwnProperty(participant_id)){
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td><td class="h4">&#8194;</td></tr>')
                }
                else {
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
                }
            }
        }
        $('#DetailMissionParticipants').modal('show');
    }

    drawDetailMissionAdmins(){
        let mission = this.mission;
        let MissionAdminsTB = $('#MissionAdminsTB');
        MissionAdminsTB.empty();

        if(Object.keys(mission['admins']).length === 1)
        {
            let admin_id = (Object.keys(mission['admins']))[0];
            let admin_name = mission['admins'][admin_id];

            MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + admin_name + '</strong></td><td class="h4">&#8194;</td></tr>')
        }
        else
        {
            for(let admin_id in mission['admins']){
                if(mission['admins'].hasOwnProperty(admin_id)){
                    MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + mission['admins'][admin_id] + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
                }
            }
        }
        $('#DetailMissionAdmins').modal('show');
    }

    drawDetailMission(){
        $('#DetailMissionTitle').val(this.mission['name']);
        $('#DetailMissionDescription').val(this.mission['description']);
        $('#DetailMission').modal('show');
    }

    drawDeleteMission(){
        $('#DeleteMissionTitle').val(this.mission['name']);
        $('#ConfirmDeleteMission').modal('show');
    }

    update_mission(mission){
        this.mission['name'] = mission['name'];
        this.mission['description'] = mission['description'];

        $('#mission-title').text(this.mission['name']);
        $('#mission-description').text(this.mission['description']);
    }

    add_participant(data){
        let mission = this.mission;

        if(!mission['participants'].hasOwnProperty(data['id'])){
            mission['participants'][data['id']] = data['name'];
            $('#ShowMissionParticipants').append('<p data-participant_id="' + data['id'] +'">' + data['name'] + '</p>');

            if($('#DetailMissionParticipants').css('display') === 'block'){
                let MissionParticipantsTB = $('#MissionParticipantsTB');
                MissionParticipantsTB.empty();

                for(let participant_id in mission['participants']){
                    if(mission['participants'].hasOwnProperty(participant_id)){
                        if(mission['admins'].hasOwnProperty(participant_id)){
                            MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td></tr>')
                        }
                        else {
                            MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
                        }
                    }
                }
            }
        }
    }

    delete_participant(data){
        let mission = this.mission;

        if(mission['participants'].hasOwnProperty(data['id'])){
            delete mission['participants'][data['id']];
            $('#ShowMissionParticipants').find('p[data-participant_id=' + data['id'] + ']').remove()

            if($('#DetailMissionParticipants').css('display') === 'block'){
                let MissionParticipantsTB = $('#MissionParticipantsTB');
                MissionParticipantsTB.empty();

                for(let participant_id in mission['participants']){
                    if(mission['participants'].hasOwnProperty(participant_id)){
                        if(mission['admins'].hasOwnProperty(participant_id)){
                            MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td></tr>')
                        }
                        else {
                            MissionParticipantsTB.append('<tr data-mission_participant="' + participant_id + '"><td><strong class="mu-text">' + mission['participants'][participant_id] + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
                        }
                    }
                }
            }
        }
    }

    add_admin(data){
        let mission = this.mission;

        if(!mission['admins'].hasOwnProperty(data['id'])){
            mission['admins'][data['id']] = data['name'];
            $('#ShowMissionAdmins').append('<p data-admin_id="' + data['id'] +'">' + data['name'] + '</p>');

            if($('#DetailMissionAdmins').css('display') === 'block'){
                let MissionAdminsTB = $('#MissionAdminsTB');
                MissionAdminsTB.empty();

                if(Object.keys(mission['admins']).length === 1)
                {
                    let admin_id = (Object.keys(mission['admins']))[0];
                    let admin_name = mission['admins'][admin_id];

                    MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + admin_name + '</strong></td></tr>')
                }
                else
                {
                    for(let admin_id in mission['admins']){
                        if(mission['admins'].hasOwnProperty(admin_id)){
                            MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + mission['admins'][admin_id] + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
                        }
                    }
                }
            }
        }
    }

    delete_admin(data){
        let mission = this.mission;

        if(mission['admins'].hasOwnProperty(data['id'])){
            delete mission['admins'][data['id']];
            $('#ShowMissionAdmins').find('p[data-admin_id=' + data['id'] + ']').remove();

            if($('#DetailMissionAdmins').css('display') === 'block'){
                let MissionAdminsTB = $('#MissionAdminsTB');
                MissionAdminsTB.empty();

                if(Object.keys(mission['admins']).length === 1)
                {
                    let admin_id = (Object.keys(mission['admins']))[0];
                    let admin_name = mission['admins'][admin_id];

                    MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + admin_name + '</strong></td></tr>')
                }
                else
                {
                    for(let admin_id in mission['admins']){
                        if(mission['admins'].hasOwnProperty(admin_id)){
                            MissionAdminsTB.append('<tr data-mission_admin="' + admin_id + '"><td><strong class="mu-text">' + mission['admins'][admin_id] + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
                        }
                    }
                }
            }
        }
    }
}