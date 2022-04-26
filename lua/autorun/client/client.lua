surface.CreateFont( "paffTools_main", {
    font = "Montserrat",
    size = 30,
    weight = 500,
    antialias = true,
    extended = true,
} )
surface.CreateFont( "paffTools_submain", {
    font = "Montserrat",
    size = 25,
    weight = 500,
    antialias = true,
    extended = true,
} )
surface.CreateFont( "paffTools_sub", {
    font = "Montserrat",
    size = 20,
    weight = 250,
    antialias = true,
    extended = true,
} )
surface.CreateFont( "paffTools_close", {
    font = "Montserrat",
    size = 30,
    weight = 250,
    antialias = true,
    extended = true,
} )
util.PrecacheModel( "models/hunter/blocks/cube025x025x025.mdl" )
local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 6 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

paffTools.firstpos = Vector(0,0,0)
paffTools.secondpos = Vector(0,0,0)
paffTools.JailZoneName = "Jail Zone"

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

local function paffAdminToolsMenu()
    if IsValid(main) then
        main:Remove()
    end
    main = vgui.Create("EditablePanel")
    main:SetSize(400,400)
    main:Center()
    main:MakePopup()
    main.Paint = function(k, w,h)
        DrawBlur(main, 2)
        drawRectOutline( 0, 0, w,h, color_white )	
        draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
    end
    local toppanel = vgui.Create("DPanel",main)
    toppanel:Dock(TOP)
    toppanel:SetTall(45)
    toppanel.Paint = function(k, w,h)
        draw.RoundedBox(0,1,1,w-1,h-1,Color(0,0,0,150))
        drawRectOutline( 0, 0, w,h, Color(0,0,0,85) )	
        draw.SimpleText( "paffAdminTools v0.3", "paffTools_main", w / 2, h/2 - 1, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local closebtn = vgui.Create("DButton", toppanel)
    closebtn:SetSize(toppanel:GetTall(),toppanel:GetTall())
    closebtn:Dock(RIGHT)
    closebtn:SetText("✖")
    closebtn:SetTextColor(color_white)
    closebtn:SetFont( "paffTools_close" )
    closebtn.DoClick = function()
        --if IsValid(paffTools.Bloackf) then paffTools.Bloackf:Remove() end
        --if IsValid(paffTools.Bloacks) then paffTools.Bloacks:Remove() end
        main:Remove()
    end
    closebtn.Paint = function(k, w,h)
    end

    local bg_panel = vgui.Create("DPanel",main)
    bg_panel:SetPos(5,50)
    bg_panel:SetSize(main:GetWide()-10,main:GetTall()-55)
    bg_panel.Paint = function(k, w,h)
    end

    local mainbg = vgui.Create( "DScrollPanel", bg_panel )
    mainbg:Dock( FILL )

    local jobrst_c = mainbg:Add( "DCollapsibleCategory" )
    jobrst_c:SetLabel( "Job restrictions" )
    jobrst_c:Dock( TOP )
    jobrst_c:SetExpanded( false )	
    jobrst_c:DockMargin( 0, 0, 0, 5 )

    local jobrestriction = vgui.Create("DPanel")
    jobrestriction:Dock(FILL)
    jobrestriction:SetTall(200)
    jobrestriction.Paint = function(k, w,h)
        draw.SimpleText( ULib and "ULX" or FAdmin and "FAdmin" or "Undetected", "paffTools_submain", w / 2, 15, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( "Enable job restriction", "paffTools_sub", 35, 32, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText( "Restricted jobs", "paffTools_sub", 10, 54, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    jobrst_c:SetContents( jobrestriction )
--
    local checkjobrestriction = vgui.Create("DCheckBox",jobrestriction)
    checkjobrestriction:SetPos(10,35)
    checkjobrestriction:SetSize(15,15)
    checkjobrestriction:SetValue(paffTools.jobsRestr)
    checkjobrestriction.OnChange = function()
        if !LocalPlayer():IsSuperAdmin() then return end
        net.Start("EditResrictedJobs")
        net.WriteBool(checkjobrestriction:GetChecked())
        net.SendToServer()
    end
--
    local alljobs_bg = vgui.Create("DPanel",jobrestriction)
    alljobs_bg:SetPos(10,80)
    alljobs_bg:SetSize(150,200)
--
    local seljobs_bg = vgui.Create("DPanel",jobrestriction)
    seljobs_bg:SetPos(main:GetWide()-160,80)
    seljobs_bg:SetSize(150,200)
--
    local alljobs = vgui.Create("DListView", alljobs_bg)
    alljobs:Dock(FILL)
    alljobs:AddColumn("Available jobs")
    alljobs:SetMultiSelect(false)
	for k,v in pairs(RPExtraTeams) do
        if !table.HasValue(paffTools.jobs_ac, v.team) then
		    alljobs:AddLine(v.name)
        end  
	end
--
    local seljobs = vgui.Create("DListView", seljobs_bg)
    seljobs:Dock(FILL)
    seljobs:AddColumn("Selected jobs")
    seljobs:SetMultiSelect(false)
	for k,v in pairs(RPExtraTeams) do
        if table.HasValue(paffTools.jobs_ac, v.team) then
		    seljobs:AddLine(v.name)
        end    
    end
--
    local seljob = vgui.Create("DButton",jobrestriction)
    seljob:SetPos(main:GetWide()/2-35,80+100-20)
    seljob:SetSize(70,40)
    seljob:SetFont("paffTools_sub")
    seljob:SetText("Select")
    seljob:SetTextColor(color_white)
    seljob.Paint = function(k, w,h)
        draw.RoundedBox(0,1,1,w-1,h-1,Color(0,0,0,150))
    end
    seljob.DoClick = function()
        if !LocalPlayer():IsSuperAdmin() then return end
        if alljobs:GetSelectedLine() then
            local selectedline = alljobs:GetLine(alljobs:GetSelectedLine())
            local selectedlinetext = alljobs:GetLine(alljobs:GetSelectedLine()):GetValue(1)
            seljobs:AddLine(selectedlinetext)
            alljobs:RemoveLine(selectedline:GetID())
            net.Start("AddRestrictedJob")
                net.WriteString(selectedlinetext)
            net.SendToServer()
        end
        if seljobs:GetSelectedLine() then
            local selectedline = seljobs:GetLine(seljobs:GetSelectedLine())
            local selectedlinetext = seljobs:GetLine(seljobs:GetSelectedLine()):GetValue(1)
            alljobs:AddLine(selectedlinetext)
            seljobs:RemoveLine(selectedline:GetID())
            net.Start("RemoveRestrictedJob")
                net.WriteString(selectedlinetext)
            net.SendToServer()
        end
    end
--
    local checkdamagerestriction = vgui.Create("DCheckBoxLabel",jobrestriction)
    checkdamagerestriction:SetPos(10,290)
    checkdamagerestriction:SetText("Enable damage disable for restricted jobs")
    checkdamagerestriction:SetTextColor(color_white)
    checkdamagerestriction:SetValue(paffTools.damageRestr)
    checkdamagerestriction:SizeToContents()		
    checkdamagerestriction:SetFont("paffTools_sub")
    checkdamagerestriction.OnChange = function()
        if !LocalPlayer():IsSuperAdmin() then return end
        net.Start("EditResrictedDamage")
        net.WriteBool(checkdamagerestriction:GetChecked())
        net.SendToServer()
    end
    
end

concommand.Add("paff_admintools", paffAdminToolsMenu)

hook.Add( "OnPlayerChat", "openmenu", function( ply, strText, bTeam, bDead ) 
    if ( ply != LocalPlayer() ) then return end
	if ( string.lower( strText ) == "/admintools" or  string.lower( strText ) == "!admintools") then 
		RunConsoleCommand("paff_admintools")
		return true
	end
end )

FAdmin.StartHooks["AdminTools"] = function()
    FAdmin.Access.AddPrivilege("AdminTools", 2)

    FAdmin.ScoreBoard.Server:AddServerSetting("Open paffAdminTools", "fadmin/icons/serversetting", Color(0, 0, 155, 255), true, paffAdminToolsMenu)
end
