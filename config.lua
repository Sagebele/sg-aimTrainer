Config = {}


Config.Locations = {}
Config.Locations.MainNpc ={}
Config.Locations.targets = {}
Config.ped = nil 
Config.cam = nil
Config.exitKey = 200
Config.enterKey = 201
Config.speed = {}

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
    coords = vector3(1374.34, 3145.22, 41), 
    lookAt = vector3(1374.87, 3143.94, 41),  
}



Config.Locations.center = {
    tempCoords = {
        near = vector3(1344.21, 3153.49, 39.5),
        medium = vector3(1312.73, 3145.09, 39.5),
        far = vector3(1287.64, 3138.36, 39.5),
    },
    coords = vector3(1312.73, 3145.09, 39.5),
    radius = 6,
}

Config.runSpeed = 10.0
