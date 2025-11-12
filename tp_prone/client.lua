local IS_PLAYER_PRONED  = false
local CURRENT_ANIM_NAME = nil

---------------------------------------------------------------
-- Local Functions
---------------------------------------------------------------

local function SetProned()   
    local player = PlayerPedId()
    
    ClearPedTasksImmediately(player)
    TaskPlayAnimAdvanced(player, "mech_crawl@base", "onfront_fwd", GetEntityCoords(player), 0.0, 0.0, GetEntityHeading(player), 1.0, 1.0, 1.0, 2, 1.0, 0, 0)
    CURRENT_ANIM_NAME = "onfront_fwd"
end

local function ProneMovement()

    local player = PlayerPedId()

    if IS_PLAYER_PRONED then
        DisableControlAction(0, 0xB2F377E8)
        DisableControlAction(0, 0x8FFC75D6)
        DisableControlAction(0, 0xF3830D8E)

        if IsControlPressed(0, 0x8FD015D8) or IsControlPressed(0, 0xD27782E3) then
            DisablePlayerFiring(player, true)

         elseif IsControlJustReleased(0, 0x8FD015D8) or IsControlJustReleased(0, 0xD27782E3) then
            DisablePlayerFiring(player, false)
        end

        if IsControlJustPressed(0, 0x8FD015D8) and not movefwd then
            movefwd = true
            TaskPlayAnimAdvanced(player, "mech_crawl@base", "onfront_fwd", GetEntityCoords(player), 0.0, 0.0, GetEntityHeading(player), 1.0, 1.0, 1.0, 1, 1.0, 0, 0)
       
            CURRENT_ANIM_NAME = "onfront_fwd"

        elseif IsControlJustReleased(0, 0x8FD015D8) and movefwd then
            TaskPlayAnimAdvanced(player, "mech_crawl@base", "onfront_fwd", GetEntityCoords(player), 0.0, 0.0, GetEntityHeading(player), 1.0, 1.0, 1.0, 2, 1.0, 0, 0)
            movefwd = false
            CURRENT_ANIM_NAME = "onfront_fwd"
        end 
        if IsControlJustPressed(0, 0xD27782E3) and not movebwd then
            movebwd = true
            TaskPlayAnimAdvanced(player, "mech_crawl@base", "onfront_bwd", GetEntityCoords(player), 0.0, 0.0, GetEntityHeading(player), 1.0, 1.0, 1.0, 1, 1.0, 0, 0)
        elseif IsControlJustReleased(0, 0xD27782E3) and movebwd then 
            TaskPlayAnimAdvanced(player, "mech_crawl@base", "onfront_bwd", GetEntityCoords(player), 0.0, 0.0, GetEntityHeading(player), 1.0, 1.0, 1.0, 2, 1.0, 0, 0)
            movebwd = false

            CURRENT_ANIM_NAME = "onfront_bwd"
        end

        if IsControlPressed(0, 0x7065027D) then
            SetEntityHeading(player, GetEntityHeading(player)+2.0 )

        elseif IsControlPressed(0, 0xB4E465B4) then
            SetEntityHeading(player, GetEntityHeading(player)-2.0 )
        end

    end
end

local ClearProneAnimation = function()
    local player = PlayerPedId()
    IS_PLAYER_PRONED = false 

    StopAnimTask(player, "mech_crawl@base", CURRENT_ANIM_NAME)
    IS_PLAYER_PRONED = false

    RemoveAnimDict("mech_crawl@base")
end

local HasNoPermittedAction = function()
    local player = PlayerPedId()

    local hogtied    = Citizen.InvokeNative(0x3AA24CCC0D451379, player)
    local handcuffed = Citizen.InvokeNative(0x74E559B3BC910685, player)

    return hogtied or handcuffed or IsPedDiving(player) or IsPedInCover(player, true) or IsPedInAnyVehicle(player, true) or IsPedDeadOrDying(player) or IsPedOnMount(player) or IsPedSwimming(player) or IsPedSwimmingUnderWater(player)

end

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------

Citizen.CreateThread(function()
    while true do

        local sleep  = 1
        local player = PlayerPedId()
    
        if HasNoPermittedAction() then 
            sleep  = 1000
            IS_PLAYER_PRONED = false

            if IS_PLAYER_PRONED then 
                ClearProneAnimation()
            end

            goto END
        end

        ProneMovement()
        DisableControlAction(0, 0x80F28E95, false)

        if not IsPauseMenuActive() then
           
            if IsDisabledControlJustPressed(0, 0x80F28E95) then
               
                if IS_PLAYER_PRONED then

                    ClearProneAnimation()
    
                elseif not IS_PLAYER_PRONED then

                    RequestAnimDict("mech_crawl@base")
                    while not HasAnimDictLoaded("mech_crawl@base") do
                        Wait(100)
                    end
                    
                    ClearPedTasksImmediately(player)
                    IS_PLAYER_PRONED = true
                    SetProned()
                
                end
           
            end
        
        end

        ::END::
        Wait(sleep)
    end
end)
