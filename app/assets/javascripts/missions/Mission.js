class Mission {
    constructor(mission, user_signed_in, user_id, mission_id){
        this.mission = mission;
        this.user_signed_in = user_signed_in;
        this.user_id = user_id;
        this.mission_id = mission_id;
    }

    get_mission_id(){
        return this.mission.id
    }

    get_mission_title(){
        return this.mission.title
    }

    get_mission_description(){
        return this.mission.description
    }

    get_mission_participants(){
        return this.mission.participants
    }

    get_mission_admins(){
        return this.mission.admins
    }

    drawDeleteMissionParticipant(){
        $('#ConfirmDeleteMissionParticipant').modal('show');
        $('#DeleteMissionParticipantTitle').text(this.mission.name);
    }

    drawDetailMissionParticipants(){
        let MissionParticipantsTB = $('#MissionParticipantsTB');
        MissionParticipantsTB.empty();

        let missionadmins_list = [];
        for(let admin of this.mission.admins){
            missionadmins_list.push(admin.id);
        }

        for(let participant of this.mission.participants){
            if (missionadmins_list.indexOf(participant.id) >= 0){
                MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td></tr>')
            }else{
                MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
            }
        }
        $('#DetailMissionParticipants').modal('show');
    }

    drawDetailMissionAdmins(){
        let MissionAdminsTB = $('#MissionAdminsTB');
        MissionAdminsTB.empty();

        if(this.mission.admins.length === 1){
            MissionAdminsTB.append('<tr data-mission_admin="' + this.mission.admins[0].id + '"><td><strong class="mu-text">' + this.mission.admins[0].name + '</strong></td></tr>')
        }else{
            for(let admin of this.mission.admins){
                MissionAdminsTB.append('<tr data-mission_admin="' + admin.id + '"><td><strong class="mu-text">' + admin.name + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
            }
        }

        $('#DetailMissionAdmins').modal('show');
    }

    drawDetailMission(){
        $('#DetailMission').modal('show');
        $('#DetailMissionTitle').val(this.mission.name);
        $('#DetailMissionDescription').val(this.mission.description);
    }

    drawDeleteMission(){
        $('#ConfirmDeleteMission').modal('show');
        $('#DeleteMissionTitle').val(this.mission.name);
    }

    update_mission(mission){
        this.mission.name = mission.name;
        this.mission.description = mission.description;

        $('#mission-title').text(this.mission.name);
        $('#mission-description').text(this.mission.description);
    }

    add_participant(added_participant){
        let mission = this.mission;
        let exist_flag = false;
        for (let participant of mission.participants){
            if(added_participant.id === participant.id){
                exist_flag = true;
                break;
            }
        }

        if(exist_flag === false){
            this.mission.participants.push(added_participant);
            $('#ShowMissionParticipants').append('<p data-participant_id="' + added_participant.id +'">' + added_participant.name + '</p>');
        }

        let display = $('#DetailMissionParticipants').css('display');
        if(display === 'block'){
            let MissionParticipantsTB = $('#MissionParticipantsTB');
            MissionParticipantsTB.empty();

            let missionadmins_list = [];
            for(let admin of this.mission.admins){
                missionadmins_list.push(admin.id);
            }

            for(let participant of this.mission.participants){
                if (missionadmins_list.indexOf(participant.id) >= 0){
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td></tr>')
                }else{
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
                }
            }
        }
    }

    delete_participant(deleted_participant){
        let mission = this.mission;
        let exist_flag = false;
        let delete_index = null;


        for(let i = 0; i < mission.participants.length; i++){
            if(deleted_participant.id === mission.participants[i].id){
                exist_flag = true;
                mission.participants.splice(i, 1);
                break;
            }
        }

        if(exist_flag === true){
            $('#ShowMissionParticipants').data('participant_id', deleted_participant.id).remove();
        }

        let display = $('#DetailMissionParticipants').css('display');
        if(display === 'block'){
            let MissionParticipantsTB = $('#MissionParticipantsTB');
            MissionParticipantsTB.empty();

            let missionadmins_list = [];
            for(let admin of this.mission.admins){
                missionadmins_list.push(admin.id);
            }

            for(let participant of this.mission.participants){
                if (missionadmins_list.indexOf(participant.id) >= 0){
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td></tr>')
                }else{
                    MissionParticipantsTB.append('<tr data-mission_participant="' + participant.id + '"><td><strong class="mu-text">' + participant.name + '</strong></td><td class="h4 delete_mission_participant">&times;</td></tr>')
                }
            }
        }
    }

    add_admin(added_admin){
        let mission = this.mission;
        let exist_flag = false;
        for (let admin of mission.admins){
            if(added_admin.id === admin.id){
                exist_flag = true;
                break;
            }
        }

        if(exist_flag === false){
            this.mission.admins.push(added_admin);
            $('#ShowMissionAdmins').append('<p data-admin_id="' + added_admin.id +'">' + added_admin.name + '</p>');
        }

        let display = $('#DetailMissionAdmins').css('display');
        if(display === 'block'){
            let MissionAdminsTB = $('#MissionAdminsTB');
            MissionAdminsTB.empty();

            if(this.mission.admins.length === 1){
                MissionAdminsTB.append('<tr data-mission_admin="' + this.mission.admins[0].id + '"><td><strong class="mu-text">' + this.mission.admins[0].name + '</strong></td></tr>')
            }else{
                for(let admin of this.mission.admins){
                    MissionAdminsTB.append('<tr data-mission_admin="' + admin.id + '"><td><strong class="mu-text">' + admin.name + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
                }
            }
        }
    }

    delete_admin(deleted_admin){
        let mission = this.mission;
        let exist_flag = false;
        let delete_index = null;


        for(let i = 0; i < mission.admins.length; i++){
            if(deleted_admin.id === mission.admins[i].id){
                exist_flag = true;
                mission.admins.splice(i, 1);
                break;
            }
        }

        if(exist_flag === true){
            $('#ShowMissionAdmins').data('admin_id', deleted_admin.id).remove();
        }

        let display = $('#DetailMissionAdmins').css('display');
        if(display === 'block'){
            let MissionAdminsTB = $('#MissionAdminsTB');
            MissionAdminsTB.empty();

            if(this.mission.admins.length === 1){
                MissionAdminsTB.append('<tr data-mission_admin="' + this.mission.admins[0].id + '"><td><strong class="mu-text">' + this.mission.admins[0].name + '</strong></td></tr>')
            }else{
                for(let admin of this.mission.admins){
                    MissionAdminsTB.append('<tr data-mission_admin="' + admin.id + '"><td><strong class="mu-text">' + admin.name + '</strong></td><td class="h4 delete_mission_admin">&times;</td></tr>')
                }
            }
        }
    }
}