Config = {}


Config.Locations = {}
Config.Locations.MainNpc ={}
Config.Locations.targets = {}
Config.ped = nil 
Config.cam = nil
Config.exitKey = 200
Config.enterKey = 201
Config.speed = {}
Config.killcount = 0
Config.playing = false

Config.Locations.MainNpc = {
    coords = vector3(1374.24, 3143.9, 39.5), 
    heading = 12.36, 
    model = "a_m_m_business_01",
    spawned = false
}

Config.targets = {
    t1 = {
        coords = vector3(0, 0, 0), -- coords will be set randomly
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil, 
            heading = 283.38,
        }
    }, 
    t2 = {
        coords = vector3(0, 0, 0),
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t3 = {
        coords = vector3(0, 0, 0),
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t4 = {
        coords = vector3(0, 0, 0),
        details = {
            model = "a_m_y_hasjew_01",
            ped = nil,
            heading = 283.38,
        }
    },
    t5 = {
        coords = vector3(0, 0, 0),
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
    radius = 6,
}

Config.speed = {
        tSpeed = 2.5, -- Speed multiplier for the target
        runSpeed = 2.5, -- Speed multiplier for running
}