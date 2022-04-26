util.AddNetworkString("AddRestrictedJob")
util.AddNetworkString("RemoveRestrictedJob")
util.AddNetworkString("OpenToolsMenu")
util.AddNetworkString("SendToolsMenu")
util.AddNetworkString("SendRestrictedJobs")
util.AddNetworkString("ReqRestrictedJobs") 
util.AddNetworkString("EditResrictedJobs") 
util.AddNetworkString("EditResrictedDamage") 
util.AddNetworkString("paffCreatePosJail") 

local function findteam(s)
    for k,v in pairs(RPExtraTeams) do
        if v.name == s then 
            return v.team
        end  
	end
end

net.Receive("AddRestrictedJob",function(len,ply)
    if !ply:IsSuperAdmin() then return end
    local jobname = net.ReadString()
    local t = file.Read( "paffAdminTools/teams.txt" )
    local tt = t.."|"..tostring(findteam(jobname))
    file.Write("paffAdminTools/teams.txt",tt)
    paffTools.UpdateJobList()
end)

net.Receive("EditResrictedJobs",function(len,ply)
    if !ply:IsSuperAdmin() then return end
    local act = paffTools.toInt(net.ReadBool())
    file.Write("paffAdminTools/teamsrestriction.txt",act)
    paffTools.UpdateJobList()
    for k,v in pairs(player.GetAll()) do
        DarkRP.notify(v, 1, 5, "The administrator changed the status of the job restriction")
    end
end)

net.Receive("RemoveRestrictedJob",function(len,ply)
    if !ply:IsSuperAdmin() then return end
    local jobname = net.ReadString()
    local t = file.Read( "paffAdminTools/teams.txt" )
    local tt = string.gsub(t, "|"..tostring(findteam(jobname)), "")
    file.Write("paffAdminTools/teams.txt",tt)
    paffTools.UpdateJobList()
end)

net.Receive("EditResrictedDamage",function(len,ply)
    if !ply:IsSuperAdmin() then return end
    local act = paffTools.toInt(net.ReadBool())
    file.Write("paffAdminTools/damagedisable.txt",act)
    paffTools.UpdateJobList()
    for k,v in pairs(player.GetAll()) do
        DarkRP.notify(v, 1, 5, "The administrator changed the status of the damage restriction")
    end
end)
