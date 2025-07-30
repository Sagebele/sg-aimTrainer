Config = {}


Config.Locations = {}
Config.Locations.MainNpc ={}
Config.Locations.targets = {}
Config.ped = nil 
Config.cam = nil
Config.exitKey = 322

Config.Locations.MainNpc = {
    coords = vector3(1374.24, 3143.9, 39.5), 
    heading = 12.36, 
    model = "a_m_m_business_01", 
}

Config.targets = {
    t1 = {
        -- coords = vector3(1316.49, 3143.13, 39.5), became random
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil, 
            heading = 283.38,
            speed = 1.5, -- Speed multiplier for the target
            runSpeed = 1.2, -- Speed multiplier for running
        }
    }, 
    t2 = {
        -- coords = vector3(1326.54, 3149.05, 39.5), became random
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t3 = {
        -- coords = vector3(1305.09, 3154.35, 39.5), became random
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t4 = {
        -- coords = vector3(1309.24, 3136.5, 39.5), became random
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t5 = {
        -- coords = vector3(1320.24, 3136.5, 39.5), became random
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
}



Config.Locations.Camera = {
    coords = vector3(1340.46, 3152.7, 50.09), 
    lookAt = vector3(1319.14, 3146.86, 40.41), 
}

Config.Locations.center = {
    coords = vector3(1306.79, 3143.55, 39.5),
    radius = 5.5,
}