local Replicated = game:GetService("ReplicatedStorage")

local Packages = Replicated:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)
local Promise = require(Packages.Promise)

local Shared = Replicated:WaitForChild("Shared")
local TypeLib = require(Shared.TypeLib)

--[[
    API:

        Functions:
    -   :EnableAsync <Promise>                              - Enables the dialogue.
    -   :DisableAsync <Promise>                             - Disables the dialogue.
    -   :SetNameAsync [name :string] <Promise>              - Sets the title of the message box (npc).
    -   :RespondAsync [message: string] <Promise>           - Starts typing out a message.
    -   :SetChoices [choices :table {inputName = label}]    - Sets the choices, set to nil to clear.

        Events:
    -   DialogueStarted <ScriptSignal>                      - Fired when a dialogue starts.
    -   DialogueEnded <ScriptSignal>                        - Fired when a dialogue stops/ends.
    -   OnResponse <ScriptSignal>                           - Fired when the users responds with one of the choices.
]]


local controller = Knit.CreateController {
    Name = "DialogueController";
    DialogueStarted = Signal.new();
    DialogueEnded = Signal.new();
    OnResponse = Signal.new();
}

local CameraController

local PlayerGui = Knit.Player:WaitForChild("PlayerGui")
local Dialogue: TypeLib.DialogueUI = PlayerGui:WaitForChild("Dialogue")

local MessageBox = Dialogue.Container.InlineResponse.Response.MessageBox
local NPCName = Dialogue.Container.InlineResponse.Response.NPCName
local ChoiceList = Dialogue.Container.Choices

function controller:EnableAsync()
    return Promise.new(function(resolve ,reject)
        Dialogue.Enabled = true
        resolve()
    end):catch(warn)
end

function controller:DisableAsync()
    return Promise.new(function(resolve, reject)
        Dialogue.Enabled = false
        resolve()
    end):catch(warn)
end

function controller:SetNameAsync(name: string)
    return Promise.new(function(resolve, reject)
        NPCName.Display.Text = name
        resolve()
    end):catch(warn)
end

function controller:RespondAsync(message: string, speed: number?)
    return Promise.new(function(resolve, reject)
        MessageBox.Message.MaxVisibleGraphemes = 0
        MessageBox.Message.Text = message
        for t=0,message:len(),1 do
            MessageBox.Message.MaxVisibleGraphemes = t
            task.wait(0.1 / (speed or 1))
        end
        resolve()
    end):catch(warn)
end

function controller:SetChoices(t: {[string]: string})
    local Directory = ChoiceList
    for _,v in Directory:GetChildren() do
        if v:IsA("ImageButton") and v.Name ~= "Template" then
            v:Destroy()
        end
    end
    if t ~= nil then
        for k,v in t do
            local OptionBtn = Dialogue.Container.Choices.Template:Clone()
            OptionBtn.Visible = true
            OptionBtn.Inner.Display.Text = v
            OptionBtn.Parent = Directory
            OptionBtn.Name = k
            OptionBtn.MouseEnter:Connect(function()
                OptionBtn.Inner.UIStroke.Transparency = 0.4
            end)
            OptionBtn.MouseLeave:Connect(function()
                OptionBtn.Inner.UIStroke.Transparency = 0.9
            end)
            OptionBtn.Activated:Connect(function(inputObject, clickCount)
                controller.OnResponse:Fire(k)
            end)
        end
    end
end

function controller:KnitStart()
    CameraController = Knit.GetController("CameraController")
end

return controller