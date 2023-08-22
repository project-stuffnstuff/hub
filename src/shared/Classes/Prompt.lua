local prompt = {}
prompt.__index = prompt

type Props = {
    Action: string;
    Object: string;
    HoldDuration: number;
    Triggers: {
        PC: Enum.KeyCode;
        Console: Enum.KeyCode;
    }
}

function prompt.new(props, parent)
    
end

return prompt