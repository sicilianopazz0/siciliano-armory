Config = {}

-- NPC Configuration
Config.NPC = {
    police = {
        model = 's_m_y_cop_01',
        position = vector3(000, 000, 000),
        heading = -90.0
    },
    ambulance = {
        model = 's_m_m_doctor_01',
        position = vector3(000, 000, 000),
        heading = -90.0
    }
}

-- Equipment for different jobs
Config.Equipaggiamento = {
    ['police'] = {
        { item = 'weapon_combatpistol', label = 'Pistola', quantity = 1 },
        { item = 'weapon_stungun', label = 'Tazer', quantity = 1 },
        { item = 'manette', label = 'Manette', quantity = 1 },
        { item = 'chiavimanette', label = 'Chiavi Manette', quantity = 1 },
        { item = 'tablet', label = 'Tablet', quantity = 1 },
        { item = 'ammo-9', label = 'Munizioni', quantity = 300 },
        { item = 'radio', label = 'Radio', quantity = 1 },
        { item = 'weapon_nightstick', label = 'Manganello', quantity = 1 }
    },
    ['ambulance'] = {
        { item = 'medikit', label = 'Medikit', quantity = 5 },
        { item = 'bandage', label = 'Bende', quantity = 10 },
        { item = 'radio', label = 'Radio', quantity = 1 },
        { item = 'tablet', label = 'Tablet', quantity = 1 }
    }
}

-- Messages
Config.Messages = {
    success = 'Hai ricevuto il tuo equipaggiamento!',
    error = 'Non hai il permesso di accedere a questo armadio!',
    no_space = 'Non hai abbastanza spazio nell\'inventario!'
}

-- Discord Webhook Configuration
Config.Discord = {
    webhookURL = '',
    colors = {
        success = 3066993,  -- Verde
        warning = 15105570, -- Arancione
        error = 16711680    -- Rosso
    }
}
