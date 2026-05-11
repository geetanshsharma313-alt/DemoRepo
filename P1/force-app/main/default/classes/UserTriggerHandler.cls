public class UserTriggerHandler {

    public static void preventLastRoleUserDeactivation(List<User> newUsers, Map<Id, User> oldUserMap) {
        Set<Id> roleIds = new Set<Id>();
        Map<Id, List<User>> usersByRole = new Map<Id, List<User>>();
        for (User u : newUsers) {
            User oldUser = oldUserMap.get(u.Id);
            if (oldUser.IsActive == true && u.IsActive == false && u.UserRoleId != null) {
                roleIds.add(u.UserRoleId);
                if (!usersByRole.containsKey(u.UserRoleId)) {
                    usersByRole.put(u.UserRoleId, new List<User>());
                }
                usersByRole.get(u.UserRoleId).add(u);
            }
        }
        if (roleIds.isEmpty()) return;
        List<AggregateResult> results = [SELECT UserRoleId roleId, COUNT(Id) total FROM User WHERE IsActive = true 
                                         AND UserRoleId IN :roleIds
                                         AND Id NOT IN :newUsers
                                         GROUP BY UserRoleId];

        Map<Id, Integer> activeUserCountByRole = new Map<Id, Integer>();
        for (AggregateResult ar : results){
            activeUserCountByRole.put((Id)ar.get('roleId'), (Integer)ar.get('total'));
        }
        for (Id roleId : usersByRole.keySet()) {
            Integer remainingUsers = activeUserCountByRole.containsKey(roleId)? activeUserCountByRole.get(roleId): 0;

            if (remainingUsers == 0) {
                for (User u : usersByRole.get(roleId)) {
                    u.addError('You cannot deactivate this user because they are the last active user in this role.');
                }
            }
        }
    }
}