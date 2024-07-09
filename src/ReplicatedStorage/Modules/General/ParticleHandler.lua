local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

----------- Initiated Variables -----------

local Assets = ReplicatedStorage.Assets
local Modules = ReplicatedStorage.Source.Modules
local EFFECT_FOLDER = Assets.Effects

local LightningBolt = require(Modules.General.LightningBolt)
local GeneralUI = require(Modules.General.GeneralUI)

--[[
    Earth circle effect
    targetPart - the origin part the circle forms around

    Returns a dictionary.
    dictionary[part] = growTween
]]
function module:EarthCircleEffect(
    targetPartCFrame : CFrame?,
    settings: {
        targetSize: number?,
        material: Enum.Material?,
        color: BrickColor?,
        blockAmount: number?,
        radius: number?,
        canCollide: boolean?,
        growthSpeed: number?,
        existDuration: number?,
    }
) : {part: Tween}

	local rayParams : RaycastParams? = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {workspace.Baseplate}
	rayParams.FilterType = Enum.RaycastFilterType.Include
	
	local angle = 0
    local dictionary = {}

    if not settings then
        settings = {}
    end
	
    for i = 1, settings.blockAmount or 30 do
        -- Target size for each part to reach
        local targetSize = settings.targetSize or 3
        local part = Instance.new("Part")

        -- Some part settings
        part.Anchored = true
        part.Size = Vector3.new(1, 1, 1)

        if settings.canCollide then
            part.CanCollide = true
        else
            part.CanCollide = false
        end
        
        part.CFrame = targetPartCFrame *
            CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0) *
            CFrame.new(settings.radius or 10, 5, 0)
        
        -- Create a raycast from the part
        local raycastResult = workspace:Raycast(
            part.CFrame.Position,
            part.CFrame.UpVector * - 10,
            rayParams
        )
        if not raycastResult then
            continue
        end

        part.Position = raycastResult.Position + Vector3.new(0, -5, 0)
        part.Material = Enum.Material.Basalt
        part.Color = settings.color or raycastResult.Instance.Color
        part.Orientation = Vector3.new(
            math.random(-180,180),
            math.random(-180,180),
            math.random(-180,180)
        )
        part.Parent = game.Workspace.EffectStorage
        
        -- Tween part from hidden position to origin position
        local tween = GeneralUI:SimpleTween(
            part,
            {
                Position = part.Position + Vector3.new(0, 5, 0),
                Size = Vector3.new(targetSize, targetSize, targetSize)
            },
            settings.growthSpeed or 0.25,
            Enum.EasingStyle.Bounce,
            Enum.EasingDirection.InOut
        )

        dictionary[part] = tween

        -- Cleanup the part a couple seconds later
        task.delay(settings.existDuration or 4, function()
            local fadeTween = GeneralUI:SimpleTween(
                part,
                {
                    Transparency = 1,
                    Position = part.Position + Vector3.new(0, -5, 0)
                },
                1
            )

            fadeTween.Completed:Connect(function()
                part:Destroy()
            end)
        end)
        
        -- Increment angle
        angle += 25
        task.wait()
    end

	
    return dictionary
end


--[[
    All args required EXCEPT easingStyle/easingdirection/addSize/addPosition/multiplyCFrame.
    If there are no tween settings, then it won't tween.
]]
function module:CreateStaticParticle(
    particleName : string | BasePart | Model,
    givenCFrameOrPosition : CFrame | Vector3,
    existDuration: number,
    tweenSettings: {
        goal: {},
        duration: number,

        -- not required
        easingStyle: Enum.EasingStyle?,
        easingDirection: Enum.EasingDirection?,
        addSize: Vector3?,
        addSizeProportional: number?,
        addPosition: Vector3?,
        multiplyCFrame: CFrame?,
        tweenToOriginSize: boolean?,
        delayBetweenEachItem: number?,
    }
): BasePart | Tween?

    local part

    local function applyPartSettings(givenPart: BasePart, parentModel: Model?)
        givenPart.CanQuery = false
        givenPart.CanTouch = false
        givenPart.CanCollide = false
        givenPart.Anchored = true
        givenPart.Parent = workspace.EffectStorage

        if typeof(givenCFrameOrPosition) == "CFrame" then
            if parentModel then
                if not parentModel.PrimaryPart then
                    givenPart.CFrame = givenCFrameOrPosition
                end
            else
                givenPart.CFrame = givenCFrameOrPosition
            end
        elseif typeof(givenCFrameOrPosition) == "Vector3" then
            givenPart.Position = givenCFrameOrPosition
        end
        
        if existDuration then
            game.Debris:AddItem(givenPart, existDuration)
        end
    end

    if typeof(particleName) == "string" then
        local targetEffect = EFFECT_FOLDER:FindFirstChild(particleName, true)
        if not targetEffect then
            warn("Couldnt find the target effect in effect folder")
            return
        end
    
        part = targetEffect:Clone()
    elseif typeof(particleName) == "Instance" then
        part = particleName:Clone()
    end

    if part:IsA("Model") then
        local dictionary = {}

        if typeof(givenCFrameOrPosition) == "CFrame" then
            if part.PrimaryPart then
                part:PivotTo(givenCFrameOrPosition)
            end
        end

        for index, component in ipairs(part:GetDescendants()) do
            if not component:IsA("BasePart") then
                continue
            end

            applyPartSettings(component, part)

            if not tweenSettings then
                continue
            end

            local goal = {}
            local originSize = component.Size

            if tweenSettings.goal then
                goal = tweenSettings.goal
            end

            if tweenSettings.tweenToOriginSize then
                goal.Size = originSize
                component.Size = Vector3.new(0.01, 0.01, 0.01)
            end

            if tweenSettings.addSize then
                goal.Size = originSize + tweenSettings.addSize
            end

            if tweenSettings.addSizeProportional then
                goal.Size = originSize * tweenSettings.addSizeProportional
            end

            if tweenSettings.addPosition then
                goal.Position = component.Position + tweenSettings.addPosition
            end

            if tweenSettings.multiplyCFrame then
                goal.CFrame = component.CFrame * tweenSettings.multiplyCFrame
            end

            local tween = TweenService:Create(
                component,
                TweenInfo.new(
                    tweenSettings.duration,
                    tweenSettings.easingStyle or Enum.EasingStyle.Quad,
                    tweenSettings.easingDirection or Enum.EasingDirection.Out,
                    0,
                    false,
                    (tweenSettings.delayBetweenEachItem or 0) * index
                ),
                goal
            )

            dictionary[component] = tween
            tween:Play()
        end

        return part, dictionary
    end

    applyPartSettings(part)

    if not tweenSettings then
        return part
    end

    local goal = {}
    local originSize = part.Size

    if tweenSettings.goal then
        goal = tweenSettings.goal
    end

    if tweenSettings.tweenToOriginSize then
        goal.Size = originSize
        part.Size = Vector3.new(0.01, 0.01, 0.01)
    end

    if tweenSettings.addSize then
        goal.Size = originSize + tweenSettings.addSize
    end

    if tweenSettings.addSizeProportional then
        goal.Size = originSize * tweenSettings.addSizeProportional
    end

    if tweenSettings.addPosition then
        goal.Position = part.Position + tweenSettings.addPosition
    end

    if tweenSettings.multiplyCFrame then
        goal.CFrame = part.CFrame * tweenSettings.multiplyCFrame
    end

    local tween = TweenService:Create(
        part,
        TweenInfo.new(
            tweenSettings.duration,
            tweenSettings.easingStyle or Enum.EasingStyle.Quad,
            tweenSettings.easingDirection or Enum.EasingDirection.Out,
            0,
            false,
            (tweenSettings.delayBetweenEachItem or 0)
        ),
        goal
    )

    tween:Play()

    return part, tween
end


function module:CreateNewBolt(item0, item1, settings: {})
    local attach0
    local attach1

    if not settings then
        settings = {}
    end

    if item0:IsA("BasePart") then
        attach0 = Instance.new("Attachment")
        attach0.Parent = item0
    elseif item0:IsA("Attachment") then
        attach0 = item0
    else
        warn("Item0 or item1 is not attachment/basepart")
        return
    end

    if item1:IsA("BasePart") then
        attach1 = Instance.new("Attachment")
        attach1.Parent = item1
    elseif item1:IsA("Attachment") then
        attach1 = item1
    else
        warn("Item0 or item1 is not attachment/basepart")
        return
    end
        
    local NewBolt = LightningBolt.new(attach0, attach1, 40)
 
    NewBolt.PulseSpeed = settings.PulseSpeed or 3
    NewBolt.PulseLength = settings.PulseLength or 1
    NewBolt.FadeLength = settings.FadeLength or 0.06
    NewBolt.MinRadius, NewBolt.MaxRadius = settings.MinRadius or 0, settings.MaxRadius or 2.4
    NewBolt.Frequency = settings.Frequency or 1
    NewBolt.AnimationSpeed = settings.AnimationSpeed or 0
    NewBolt.Thickness = settings.Thickness or 1

    NewBolt.Color = settings.Color or Color3.fromRGB(85, math.random(125, 193), 255)
end


--[[
    color in settings is required
]]
function module:RopeLink(
    part1 : BasePart,
    part2 : any, 
    settings: {
        ["Color"]: BrickColor,
        ["Visible"]: boolean?,
        ["Length"]: number?,
        ["Elasticity"]: number?, -- 0 or 1
        ["Thickness"]: number?,
    }
)

    if not settings then
        settings = {}
    end

    local rope = Instance.new("RopeConstraint")
    rope.Visible = settings.Visible or true
    rope.Length = settings.Length or 20
    rope.Color = settings.Color
    rope.Thickness = 0.25 or settings.Thickness
    rope.Restitution = .25 or settings.Elasticity

    local attach0 = Instance.new("Attachment")
    attach0.Parent = part1

    local attach1 = Instance.new("Attachment")
    attach1.Parent = part2

    rope.Attachment0 = attach0
    rope.Attachment1 = attach1
    rope.Parent = attach0

    return attach0, attach1, rope
end

function module:TrailLink(
    targetPart : BasePart?,
    trailName : any?
)
    local trail = EFFECT_FOLDER:FindFirstChild(trailName, true)
    if not trail then
        warn("No trail in this container named: ", trailName)
        return
    end

    trail = trail:Clone()

    local attach0 = Instance.new("Attachment")
    attach0.Parent = targetPart
    attach0.CFrame = attach0.CFrame * CFrame.new(
        0,
        targetPart.Size.Y / 2,
        0
    )

    local attach1 = Instance.new("Attachment")
    attach1.Parent = targetPart
    attach1.CFrame = attach0.CFrame * CFrame.new(
        0,
        -targetPart.Size.Y / 2,
        0
    )

    trail.Attachment0 = attach0
    trail.Attachment1 = attach1
    trail.Parent = attach0

    return attach0, attach1, trail
end

function module:BeamLink(
    part0 : BasePart,
    part1 : BasePart,
    container : any
)

    local beam = container:FindFirstChild("Beam", true)
    if not beam then
        warn("No beam in this container")
        return
    end

    beam = beam:Clone()

    local attach0 = Instance.new("Attachment")
    attach0.Parent = part0

    local attach1 = Instance.new("Attachment")
    attach1.Parent = part1

    beam.Attachment0 = attach0
    beam.Attachment1 = attach1
    beam.Parent = attach0

    return attach0, attach1
end


function module:PulseUntilDestroyed(
    part: BasePart?,
    particleName: string?,
    pulseDelay: number?,
    callback: any?
)

    local particleContainer : BasePart? = EFFECT_FOLDER:FindFirstChild(particleName, true)
    if not particleContainer then
        warn("Particle of that name cannot be found")
        return
    end
    
    local allParticles = {}
    for index, particle in ipairs(particleContainer:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        local copy = particle:Clone()
        copy.Parent = part

        table.insert(allParticles, copy)
    end

    task.spawn(function()
        repeat
            for _, particle in ipairs(allParticles) do
                if not particle then
                    continue
                end

                if not particle:IsDescendantOf(workspace) then
                    continue
                end

                if not particle:IsA("ParticleEmitter") then
                    continue
                end
        
                particle:Emit(particle.Rate)
            end
            callback()
            
            task.wait(pulseDelay or 1)
        until not part or not part:IsDescendantOf(workspace)

        allParticles = nil
    end)
end

-- If attribute name is provided, when the attribute changes to nil, then will stop pulsing
function module:PulseUntilDeath(
    core : BasePart?,
    humanoid : Humanoid?,
    particleName : string?,
    pulseDelay : number?,
    attributeName : string
)

    local attach = Instance.new("Attachment")
    attach.Parent = core

    local allParticles = {}
    local particleContainer : BasePart? = EFFECT_FOLDER:FindFirstChild(particleName, true)
    
    if not particleContainer then
        warn("Particle of that name cannot be found")
        return
    end

    for index, particle in ipairs(particleContainer:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        local copy = particle:Clone()
        copy.Parent = attach
        copy:Emit(particle.Rate)

        table.insert(allParticles, copy)
    end

    local attributeChangeConnection

    local function destroyParticles()
        if attach then
            attach:Destroy()
        end
        
        allParticles = nil

        if attributeChangeConnection then
            attributeChangeConnection:Disconnect()
            attributeChangeConnection = nil
        end
    end

    task.spawn(function()
        while humanoid and humanoid.Health > 0 do
            if not allParticles then
                break
            end

            for _, particle in ipairs(allParticles) do
                particle:Emit(particle.Rate)
            end

            task.wait(pulseDelay)

            if not core then
                break
            end

            if not core:IsDescendantOf(workspace) then
                break
            end
        end

        destroyParticles()
    end)

    if not attributeName then
        return
    end

    local model : Model? = humanoid.Parent
    attributeChangeConnection = model:GetAttributeChangedSignal(attributeName)
    :Connect(function()
        if model:GetAttribute(attributeName) then 
            return
        end

        destroyParticles()
    end)
end

function module:PlayParticle(
    particleContainerName : string,
    part : BasePart,
    special : table?
) : BasePart?

    local container : BasePart? = EFFECT_FOLDER:FindFirstChild(particleContainerName, true)
    if not container then
        warn("No particle of this name in spelleffects")
        return
    end

    container = container:Clone()

    container.CanCollide = false
    container.CanQuery = false
    container.CanTouch = false
    container.Massless = true
    container.Anchored = true

    container.Position = part.Position
    container.Parent = workspace.EffectStorage

    local weld = Instance.new("WeldConstraint")
    weld.Parent = container
    weld.Part0 = part
    weld.Part1 = container
    container.Anchored = false

    self:EmitParticles(container, special)

    return container
end


function module:PlayParticleAtPosition(
    particleContainerName : string?,
    positionOrCFrame : Vector3 | CFrame,
    special : table?
) : BasePart?


    local container : BasePart? = EFFECT_FOLDER:FindFirstChild(particleContainerName, true)
    if not container then
        warn("No particle of this name in spelleffects")
        return
    end

    container = container:Clone()

    container.CanCollide = false
    container.CanQuery = false
    container.CanTouch = false
    container.Massless = true
    container.Anchored = true

    if typeof(positionOrCFrame) == "Vector3" then
        container.Position = positionOrCFrame
    elseif typeof(positionOrCFrame) == "CFrame" then
        container.CFrame = positionOrCFrame
    end
    
    container.Parent = workspace.EffectStorage

    self:EmitParticles(container, special)

    return container
end


function module:EmitInstant(item : any?)
    for _, particle in ipairs(item:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        particle:Emit(particle.Rate)
    end
end


function module:EmitParticles(item : any?, special : table?)
    local longestLifetime = 1

    for _, particle in ipairs(item:GetDescendants()) do
        if not particle:IsA("ParticleEmitter") then
            continue
        end

        particle.Enabled = false
        particle:Emit(particle.Rate)

        if particle.Lifetime.Max > longestLifetime then
            longestLifetime = particle.Lifetime.Max
        end

        if not special then
            continue
        end

        for key, value in pairs(special) do
            if key ~= particle.Name then
                continue
            end

            local increment = value[1]
            local delayTime = value[2]

            for i = 1, increment do
                task.delay(delayTime * i, function()
                    particle:Emit(particle.Rate)
                end)
            end

            local totalTime = particle.Lifetime.Max * increment * delayTime
            if totalTime > longestLifetime then
                longestLifetime = totalTime
            end
        end
    end


    task.delay(longestLifetime + 3, function()
        item:Destroy()
    end)
end


return module
