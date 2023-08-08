

import Foundation


struct MissionTransformer {
    static func transform(firestoreMission: FirestoreMission) -> AppGroupMission {
        return AppGroupMission(id: firestoreMission.id,
                               selectedTime1: firestoreMission.selectedTime1,
                               selectedTime2: firestoreMission.selectedTime2,
                               currentStore: firestoreMission.currentStore,
                               missionType: firestoreMission.missionType,
                               imageName: firestoreMission.imageName,
                               missionStatus: firestoreMission.missionStatus,
                               actualAmount: firestoreMission.actualAmount)
    }
    
    static func transformToFirestore(appGroupMission: AppGroupMission) -> FirestoreMission {
        return FirestoreMission(id: appGroupMission.id,
                                selectedTime1: appGroupMission.selectedTime1,
                                selectedTime2: appGroupMission.selectedTime2,
                                currentStore: appGroupMission.currentStore,
                                missionType: appGroupMission.missionType,
                                imageName: appGroupMission.imageName,
                                missionStatus: appGroupMission.missionStatus,
                                actualAmount: appGroupMission.actualAmount)
    }
}
