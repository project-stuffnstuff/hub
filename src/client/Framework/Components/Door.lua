local Replicated = game:GetService("ReplicatedStorage")
local Tween = game:GetService("TweenService")

local Packages = Replicated:WaitForChild("Packages")
local Shared = Replicated:WaitForChild("Shared")

local Knit = require(Packages.Knit)
local WaitFor = require(Packages.WaitFor)
local Component = require(Packages.Component)

type Props = {[string]: any}

local tag = Component.new {
    Tag = "Door"
}

local DoorTweenInfo = TweenInfo.new(
    1.3,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

function tag:Construct()
    local door = self.Instance
    self.door = door
    self.opened = false
    local hitbox = door.PrimaryPart
    local Prompt = Instance.new("ProximityPrompt", hitbox)
    Prompt.Name = "Interaction"
    Prompt.ActionText = "Open"
    Prompt.ObjectText = "Door"
    Prompt.RequiresLineOfSight = false
    self.Prompt = Prompt
    self.Hinge = door.DoorPart:WaitForChild("Hinge"):WaitForChild("Hinger")
    --animations
    WaitFor.Descendant(self.Instance, "Hinger"):await()
    self.Anim1 = Tween:Create(self.Hinge, DoorTweenInfo, {C0 = CFrame.new(self.Hinge.C0.Position) * CFrame.Angles(0,math.deg(45),0)})
    self.Anim2 = Tween:Create(self.Hinge, DoorTweenInfo, {C0 = CFrame.new(self.Hinge.C0.Position) * CFrame.Angles(0,math.deg(0),0)})
end

function tag:Open()
    self.Anim1:Play()
    return self.Anim1
end

function tag:Close()
    self.Anim2:Play()
    return self.Anim2
end

function tag:SetPrompt(visible: boolean)
    self.Prompt.Enabled = visible
end

function tag:Start()
    local door = self.door
    self.Prompt.Triggered:Connect(function(playerWhoTriggered)
        if self.opened == false then
            self.opened = true
            self:SetPrompt(false)
            local A = self:Open()
            A.Completed:Wait()
            task.wait(4)
            local B = self:Close()
            B.Completed:Wait()
            self:SetPrompt(true)
            self.opened = false
        end
    end)
end

return tag