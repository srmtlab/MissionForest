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
        $('#DeleteMissionTitle').text(this.mission.title);
    }

    drawDetailMission(){
        $('#DetailMission').modal('show');
        $('#DetailMissionTitle').val(this.mission.title);
        $('#DetailMissionDescription').val(this.mission.description);
    }
}