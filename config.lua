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

Config.Locations.targets = {
    t1 = {
        coords = vector3(1316.49, 3143.13, 39.5),
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil, 
            heading = 283.38,
        }
    }, 
    t2 = {
        coords = vector3(1326.54, 3149.05, 39.5),
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t3 = {
        coords = vector3(1305.09, 3154.35, 39.5),
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