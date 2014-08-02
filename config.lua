local aspectRatio = display.pixelHeight / display.pixelWidth

application =
{
    content = 
    {
        width = aspectRatio > 1.5 and 800 or math.ceil( 1200 / aspectRatio ),
        height = aspectRatio < 1.5 and 1200 or math.ceil( 800 * aspectRatio ),
        -- "letterbox" is akin to putting black borders around an SD show on an HD television
        scale = "letterbox",
        -- scale = "zoomEven",
        -- scale = "zoomStretch",

        -- the suffix for retina display
        imageSuffix = 
        {
            ["-HD"] = 1.3
        },
        -- defaults to 30
        fps = 30,
    },
    -- defaults to true, just for doc's sake.
    showRuntimeErrors = true,
    -- Corona SDK Analytics enabled by default
    launchPad = true
}