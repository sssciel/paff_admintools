timer.Simple(.1, function()  

    paffTools = {}
    paffTools.Activated = nil
    paffTools.Jobs = nil
    paffTools.jobs_ac = {} 
    paffTools.jobsRestr = false
    paffTools.damageRestr = false
    
    function paffTools.toBool(a)
        if a == 0 or a == "0" then
            return false
        end
        return true
    end

    function paffTools.toInt(a)
        if a == true or a == "true" then
            return "1"
        end
        return "0"
    end

    local teamsstring 
    if SERVER then
        if !(file.Exists("paffAdminTools", "DATA")) then
            file.CreateDir("paffAdminTools", "DATA")
            file.Write( "paffAdminTools/teams.txt", "|1" )
            file.Write( "paffAdminTools/teamsrestriction.txt", "0" )
            file.Write( "paffAdminTools/damagedisable.txt", "0" )
        end 
    end
    
    if CLIENT then
        net.Start("ReqRestrictedJobs") 
        net.SendToServer()
        net.Receive("SendRestrictedJobs",function() 
            paffTools.jobs_ac = {} 
            teamsstring = net.ReadString()
            paffTools.jobsRestr = paffTools.toBool(net.ReadString())
            paffTools.damageRestr = paffTools.toBool(net.ReadString())
            local teamtbl = string.Explode( "|", teamsstring)
            for k,v in pairs(teamtbl) do
                table.insert(paffTools.jobs_ac,tonumber(v)) 
            end
        end) 
    end
    if SERVER then
        local restrtext = file.Read( "paffAdminTools/teamsrestriction.txt" )
        local restrjob = file.Read( "paffAdminTools/damagedisable.txt" )
        function paffTools.UpdateJobList()
            local restrtext = file.Read( "paffAdminTools/teamsrestriction.txt" )
            local restrjob = file.Read( "paffAdminTools/damagedisable.txt" )
            paffTools.jobsRestr = paffTools.toBool(restrtext)
            paffTools.jobs_ac = {}  
            paffTools.damageRestr = paffTools.toBool(restrjob)
            teamsstring = file.Read( "paffAdminTools/teams.txt" )
            local teamtbl = string.Explode( "|", teamsstring)
            for k,v in pairs(teamtbl) do
                table.insert(paffTools.jobs_ac,tonumber(v))  
            end
            for k,v in pairs(player.GetAll()) do
                net.Start("SendRestrictedJobs")
                net.WriteString(teamsstring)
                net.WriteString(restrtext)
                net.WriteString(restrjob)
                net.Send(v)
            end
        end
        net.Receive("ReqRestrictedJobs",function(len,ply)
            net.Start("SendRestrictedJobs")
            net.WriteString(teamsstring)
            net.WriteString(restrtext)
            net.WriteString(restrjob)
            net.Send(ply)            
        end)
        paffTools.UpdateJobList()
    end
    local fadmin = FAdmin and true or false -- is Fadmin
    local ulxx = ULib and true or false -- is ULX
    if fadmin and ulxx then
        MsgC( Color( 255, 0, 0 ), "Attention, you have two addons installed at once: ULX and FAdmin. This can create execution errors. I strongly advise you to use only one admin mod \n" )
        MsgC( Color( 255, 0, 0 ), "--------------------------------------------------------------------------------------------------------------------------------------------------- \n" )
        MsgC( Color( 255, 0, 0 ), "Attention, you have two addons installed at once: ULX and FAdmin. This can create execution errors. I strongly advise you to use only one admin mod \n" )
    end
    if fadmin then -- block fadmin access         
        function FAdmin.Access.PlayerHasPrivilege(ply, priv, target, ignoreImmunity)
            if FAdmin.Access.PlayerIsHost(ply) then return true end
            if ply:IsSuperAdmin() then return true end
            if paffTools.jobsRestr and !table.HasValue(paffTools.jobs_ac,ply:Team()) then return false end
            if not FAdmin.Access.Privileges[priv] then return ply:IsAdmin() end -- i just copied FAdmin code, because i had stack overflow error
            local Usergroup = ply:GetUserGroup()
            local canTarget = hook.Call("FAdmin_CanTarget", nil, ply, priv, target)
            if canTarget ~= nil then
                return canTarget
            end
            if FAdmin.GlobalSetting.Immunity and
                not ignoreImmunity and
                not isstring(target) and IsValid(target) and target ~= ply and
                FAdmin.Access.Groups[Usergroup] and FAdmin.Access.Groups[target:GetUserGroup()] and
                FAdmin.Access.Groups[Usergroup].immunity and FAdmin.Access.Groups[target:GetUserGroup()].immunity and
                FAdmin.Access.Groups[target:GetUserGroup()].immunity >= FAdmin.Access.Groups[Usergroup].immunity then
                return false
            end 
            if not FAdmin.Access.Groups[Usergroup] then return end
            
            if FAdmin.Access.Groups[Usergroup].PRIVS[priv] then
                return true
            end
            if CLIENT and ply.FADMIN_PRIVS and ply.FADMIN_PRIVS[priv] then return true end     
            return false    
        end
        hook.Remove( 'PlayerNoClip', 'FAdmin_noclip' )
        hook.Add( "PlayerNoClip", "FAdmin_noclip", function( ply )
            if not FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") then return end
            return true
        end)
    end
    if ulxx and SERVER then
        local ucl = ULib.ucl
        function ucl.query( ply, access, hide )
            if SERVER and (not ply:IsValid() or (not hide and ply:IsListenServerHost())) then return true end
            if ply:IsSuperAdmin() then return true end
            if paffTools.jobsRestr and !table.HasValue(paffTools.jobs_ac,ply:Team()) then return false end
            if access == nil then return true end
        
            access = access:lower()
        
            local unique_id = ply:UniqueID()
            if CLIENT and game.SinglePlayer() then
                unique_id = "1"
            end
        
            if not ucl.authed[ unique_id ] then return error( "[ULIB] Unauthed player" ) end 
            local playerInfo = ucl.authed[ unique_id ]

            if table.HasValue( playerInfo.deny, access ) then return false end 
            if table.HasValue( playerInfo.allow, access ) then return true end
            if playerInfo.allow[ access ] then return true, playerInfo.allow[ access ] end 

            local group = ply:GetUserGroup()
            while group do 
                local groupInfo = ucl.groups[ group ]
                if not groupInfo then return error( "[ULib] Player " .. ply:Nick() .. " has an invalid group (" .. group .. "), aborting. Please be careful when modifying the ULib files!" ) end
                if table.HasValue( groupInfo.allow, access ) then return true end
                if groupInfo.allow[ access ] then return true, groupInfo.allow[ access ] end
        
                group = ucl.groupInheritsFrom( group )
            end

            return nil
        end
    end
    hook.Add("EntityTakeDamage", "ssssPaff", function(target, dmginfo)
        local attkr = dmginfo:GetAttacker()
        if paffTools.damageRestr then
          if(IsValid(attkr) && IsValid(target) && attkr:IsPlayer() && target:IsPlayer() && attkr != target) then
            if table.HasValue(paffTools.jobs_ac,attkr:Team()) then 
              dmginfo:ScaleDamage(0)
              DarkRP.notify(attkr, 1, 5, "You can't do damage in a restricted job")
            end
          end
          return dmginfo
        end 
      end )
end)