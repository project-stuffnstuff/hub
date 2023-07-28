export type DialogueUI = ScreenGui&{
    Container: Frame&{
        Choices: Frame&{
            UIListLayout: UIListLayout;
            [ImageButton]: ImageButton&{
                Inner: Frame&{
                    Display: TextLabel;
                    UIStroke: UIStroke
                }
            }
        };
        InlineResponse: Frame&{
            Response: Frame&{
                MessageBox: Frame&{
                    LeftDecor: Frame&{
                        TextLabel: TextLabel;
                    };
                    RightDecor: Frame&{
                        TextLabel: TextLabel
                    };
                    Message: TextLabel
                };
                NPCName: Frame&{
                    Display: TextLabel
                }
            }
        }
    }
}

export type Dialogue = {
    HelloMessage: string;
    GoodbyeMessage: string?;
    Choices: {[string]: {
        Response: string;
        
    }}?
}

return {}