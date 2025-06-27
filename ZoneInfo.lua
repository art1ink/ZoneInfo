-- Инициализация аддона
local addonName = "ZoneInfo"
local widget = {}
local ZI_GlobalSavedVars = {}
local ZI_CharSavedVars = {}
local MAX_WIDTH = 500
local FONT_SIZE = "ZoFontGame"
local isPositionLocked = false
local wasVisibleBeforeHide = false

-- Определение языка системы
local languageCode = GetCVar("language.2")
local languageMap = {
    ["en"] = "en", -- английский
    ["ru"] = "ru", -- русский
    ["fr"] = "fr", -- французский
    ["de"] = "de", -- немецкий
    ["ua"] = "ua"  -- украинский
}
local currentLanguage = languageMap[languageCode] or "en"

-- Локализация
local L = {
    -- Общие термины
    loading = {
        en = "Loading...",
        ru = "Загрузка...",
        fr = "Chargement...",
        de = "Laden...",
        ua = "Завантаження..."
    },
    unavailable = {
        en = "unavailable",
        ru = "недоступны",
        fr = "indisponible",
        de = "nicht verfügbar",
        ua = "недоступні"
    },
    unknown = {
        en = "unknown",
        ru = "неизвестно",
        fr = "inconnu",
        de = "unbekannt",
        ua = "невідомо"
    },
    
    -- Интерфейс
    zone = {
        en = "Zone",
        ru = "Зона",
        fr = "Zone",
        de = "Gebiet",
        ua = "Зона"
    },
    subzone = {
        en = "Location",
        ru = "Локация",
        fr = "Sous-zone",
        de = "Standort",
        ua = "Локація"
    },
    texture = {
        en = "Texture",
        ru = "Текстура",
        fr = "Texture",
        de = "Textur",
        ua = "Текстура"
    },
    coords = {
        en = "Coordinates",
        ru = "Координаты",
        fr = "Coordonnées",
        de = "Koordinaten",
        ua = "Координати"
    },
    x = {
        en = "X",
        ru = "X",
        fr = "X",
        de = "X",
        ua = "X"
    },
    y = {
        en = "Y",
        ru = "Y",
        fr = "Y",
        de = "Y",
        ua = "Y"
    },
    
    -- Сообщения
    loaded = {
        en = "ZoneInfo loaded! |cFF0000/zi|r - toggle visibility",
        ru = "ZoneInfo загружен! |cFF0000/zi|r - управление видимостью",
        fr = "ZoneInfo chargé! |cFF0000/zi|r - basculer la visibilité",
        de = "ZoneInfo geladen! |cFF0000/zi|r - Sichtbarkeit umschalten",
        ua = "ZoneInfo завантажено! |cFF0000/zi|r - керування видимістю"
    },
    position_locked = {
        en = "Window position locked",
        ru = "Положение окна зафиксировано",
        fr = "Position de la fenêtre verrouillée",
        de = "Fensterposition gesperrt",
        ua = "Положення вікна зафіксовано"
    },
    position_unlocked = {
        en = "Window position unlocked",
        ru = "Положение окна разблокировано",
        fr = "Position de la fenêtre déverrouillée",
        de = "Fensterposition entsperrt",
        ua = "Положення вікна розблоковано"
    },
    global_position = {
        en = "Position saved for ALL characters",
        ru = "Позиция сохраняется для ВСЕХ персонажей",
        fr = "Position enregistrée pour TOUS les personnages",
        de = "Position für ALLE Charaktere gespeichert",
        ua = "Позиція зберігається для ВСІХ персонажів"
    },
    personal_position = {
        en = "Position saved for THIS character only",
        ru = "Позиция сохраняется ТОЛЬКО для этого персонажа",
        fr = "Position enregistrée uniquement pour CE personnage",
        de = "Position nur für DIESEN Charakter gespeichert",
        ua = "Позиція зберігається ТІЛЬКИ для цього персонажа"
    },
    window_shown = {
        en = "Window shown",
        ru = "Окно показано",
        fr = "Fenêtre affichée",
        de = "Fenster angezeigt",
        ua = "Вікно показано"
    },
    window_hidden = {
        en = "Window hidden",
        ru = "Окно скрыто",
        fr = "Fenêtre masquée",
        de = "Fenster ausgeblendet",
        ua = "Вікно приховано"
    },
    position_reset = {
        en = "Position reset",
        ru = "Позиция сброшена",
        fr = "Position réinitialisée",
        de = "Position zurückgesetzt",
        ua = "Позицію скинуто"
    },
    failed_create = {
        en = "Failed to create widget!",
        ru = "Ошибка создания виджета!",
        fr = "Échec de la création du widget!",
        de = "Fehler beim Erstellen des Widgets!",
        ua = "Помилка створення віджета!"
    },
    
    -- Команды помощи
    commands_title = {
        en = "ZoneInfo commands:",
        ru = "Команды ZoneInfo:",
        fr = "Commandes ZoneInfo:",
        de = "ZoneInfo Befehle:",
        ua = "Команди ZoneInfo:"
    },
    toggle_help = {
        en = "|cFF0000/zi|r - toggle visibility",
        ru = "|cFF0000/zi|r - переключить видимость",
        fr = "|cFF0000/zi|r - basculer la visibilité",
        de = "|cFF0000/zi|r - Sichtbarkeit umschalten",
        ua = "|cFF0000/zi|r - переключити видимість"
    },
    show_help = {
        en = "|cFF0000/zi 1|r - show window",
        ru = "|cFF0000/zi 1|r - показать окно",
        fr = "|cFF0000/zi 1|r - afficher la fenêtre",
        de = "|cFF0000/zi 1|r - Fenster anzeigen",
        ua = "|cFF0000/zi 1|r - показати вікно"
    },
    hide_help = {
        en = "|cFF0000/zi 0|r - hide window",
        ru = "|cFF0000/zi 0|r - скрыть окно",
        fr = "|cFF0000/zi 0|r - masquer la fenêtre",
        de = "|cFF0000/zi 0|r - Fenster ausblenden",
        ua = "|cFF0000/zi 0|r - приховати вікно"
    },
    lock_help = {
        en = "|cFF0000/zi lock|r - lock position",
        ru = "|cFF0000/zi lock|r - фиксация положения",
        fr = "|cFF0000/zi lock|r - verrouiller la position",
        de = "|cFF0000/zi lock|r - Position sperren",
        ua = "|cFF0000/zi lock|r - фіксація положення"
    },
    global_help = {
        en = "|cFF0000/zi global|r - global position",
        ru = "|cFF0000/zi global|r - глобальная позиция",
        fr = "|cFF0000/zi global|r - position globale",
        de = "|cFF0000/zi global|r - globale Position",
        ua = "|cFF0000/zi global|r - глобальна позиція"
    },
    reset_help = {
        en = "|cFF0000/zi reset|r - reset position",
        ru = "|cFF0000/zi reset|r - сброс позиции",
        fr = "|cFF0000/zi reset|r - réinitialiser la position",
        de = "|cFF0000/zi reset|r - Position zurücksetzen",
        ua = "|cFF0000/zi reset|r - скинути позицію"
    }
}

-- Функция локализации
local function _(textKey)
    return L[textKey][currentLanguage] or L[textKey]["en"] or textKey
end

-- Основная функция создания виджета
function CreateZoneInfoWidget()
    -- Создание фрейма
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("ZoneInfoFrame")
    frame:SetDimensions(350, 100)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 50)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetDrawLayer(0)
    frame:SetDrawTier(0)
    frame:SetHandler("OnMoveStop", function() 
        if not isPositionLocked then
            if ZI_CharSavedVars.lockPosition then
                ZI_GlobalSavedVars.x = frame:GetLeft()
                ZI_GlobalSavedVars.y = frame:GetTop()
            else
                ZI_CharSavedVars.x = frame:GetLeft()
                ZI_CharSavedVars.y = frame:GetTop()
            end
        end
    end)
    
    -- Фон
    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 0.8)
    bg:SetEdgeTexture("", 8, 2, 2)
    
    -- Текст зоны
    local zoneText = WINDOW_MANAGER:CreateControl("$(parent)Zone", frame, CT_LABEL)
    zoneText:SetAnchor(TOP, frame, TOP, 0, 8)
    zoneText:SetFont("ZoFontGameBold")
    zoneText:SetColor(1, 0.8, 0.3, 1)
    zoneText:SetMaxLineCount(1)
    zoneText:SetText(zo_strformat("<<1>>: <<2>>", _("zone"), _("loading")))
    
    -- Текст подзоны
    local subzoneText = WINDOW_MANAGER:CreateControl("$(parent)Subzone", frame, CT_LABEL)
    subzoneText:SetAnchor(TOP, zoneText, BOTTOM, 0, 3)
    subzoneText:SetFont(FONT_SIZE)
    subzoneText:SetColor(0.8, 1, 0.8, 1)
    subzoneText:SetMaxLineCount(1)
    subzoneText:SetText("")
    
    -- Текст текстуры
    local textureText = WINDOW_MANAGER:CreateControl("$(parent)Texture", frame, CT_LABEL)
    textureText:SetAnchor(TOP, subzoneText, BOTTOM, 0, 3)
    textureText:SetFont(FONT_SIZE)
    textureText:SetColor(0.8, 0.8, 1, 1)
    textureText:SetText(zo_strformat("<<1>>: <<2>>", _("texture"), _("loading")))
    
    -- Текст координат
    local coordText = WINDOW_MANAGER:CreateControl("$(parent)Coords", frame, CT_LABEL)
    coordText:SetAnchor(TOP, textureText, BOTTOM, 0, 3)
    coordText:SetFont(FONT_SIZE)
    coordText:SetColor(1, 1, 1, 1)
    coordText:SetText(zo_strformat("<<1>>: <<2>>", _("coords"), _("loading")))
    
    -- Кнопка скрытия/показа
    local toggleBtn = WINDOW_MANAGER:CreateControl("$(parent)ToggleBtn", frame, CT_BUTTON)
    toggleBtn:SetDimensions(20, 20)
    toggleBtn:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -5, 5)
    toggleBtn:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
    toggleBtn:SetMouseOverTexture("/esoui/art/buttons/closebutton_mouseover.dds")
    toggleBtn:SetHandler("OnClicked", function()
        frame:SetHidden(not frame:IsHidden())
        if ZI_CharSavedVars.lockPosition then
            ZI_GlobalSavedVars.hidden = frame:IsHidden()
        else
            ZI_CharSavedVars.hidden = frame:IsHidden()
        end
    end)
    
    -- Кнопка фиксации положения
    local lockBtn = WINDOW_MANAGER:CreateControl("$(parent)LockBtn", frame, CT_BUTTON)
    lockBtn:SetDimensions(20, 20)
    lockBtn:SetAnchor(RIGHT, toggleBtn, LEFT, -5, 0)
    lockBtn:SetNormalTexture("/esoui/art/miscellaneous/lock_normal.dds")
    lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/lock_mouseover.dds")
    lockBtn:SetHandler("OnClicked", function()
        isPositionLocked = not isPositionLocked
        frame:SetMouseEnabled(not isPositionLocked)
        
        if isPositionLocked then
            lockBtn:SetNormalTexture("/esoui/art/miscellaneous/locked_normal.dds")
            lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/locked_mouseover.dds")
            d("ZoneInfo: " .. _("position_locked"))
        else
            lockBtn:SetNormalTexture("/esoui/art/miscellaneous/lock_normal.dds")
            lockBtn:SetMouseOverTexture("/esoui/art/miscellaneous/lock_mouseover.dds")
            d("ZoneInfo: " .. _("position_unlocked"))
        end
    end)
    
    -- Кнопка глобальной позиции
    local globalBtn = WINDOW_MANAGER:CreateControl("$(parent)GlobalBtn", frame, CT_BUTTON)
    globalBtn:SetDimensions(20, 20)
    globalBtn:SetAnchor(RIGHT, lockBtn, LEFT, -5, 0)
    globalBtn:SetNormalTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_up.dds")
    globalBtn:SetMouseOverTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_over.dds")
    globalBtn:SetHandler("OnClicked", function()
        ZI_CharSavedVars.lockPosition = not ZI_CharSavedVars.lockPosition
        
        if ZI_CharSavedVars.lockPosition then
            globalBtn:SetNormalTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_down.dds")
            d("ZoneInfo: " .. _("global_position"))
        else
            globalBtn:SetNormalTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_up.dds")
            d("ZoneInfo: " .. _("personal_position"))
        end
        
        -- Применить новую позицию
        ApplyPosition(frame)
    end)
    
    return {
        frame = frame,
        bg = bg,
        zoneText = zoneText,
        subzoneText = subzoneText,
        textureText = textureText,
        coordText = coordText,
        toggleBtn = toggleBtn,
        lockBtn = lockBtn,
        globalBtn = globalBtn
    }
end

-- Применить правильную позицию окна
function ApplyPosition(frame)
    if not frame then return end
    
    if ZI_CharSavedVars.lockPosition then
        -- Глобальная позиция для всех персонажей
        if ZI_GlobalSavedVars.x and ZI_GlobalSavedVars.y then
            frame:ClearAnchors()
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZI_GlobalSavedVars.x, ZI_GlobalSavedVars.y)
        end
        frame:SetHidden(ZI_GlobalSavedVars.hidden or false)
    else
        -- Персональная позиция
        if ZI_CharSavedVars.x and ZI_CharSavedVars.y then
            frame:ClearAnchors()
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZI_CharSavedVars.x, ZI_CharSavedVars.y)
        end
        frame:SetHidden(ZI_CharSavedVars.hidden or false)
    end
end

-- Функция для адаптивного изменения размера окна
local function AdjustWindowSize()
    if not widget or not widget.frame then return end
    
    -- Рассчитываем необходимую ширину
    local maxWidth = 0
    maxWidth = math.max(maxWidth, widget.zoneText:GetTextWidth() + 40)
    maxWidth = math.max(maxWidth, widget.subzoneText:GetTextWidth() + 40)
    maxWidth = math.max(maxWidth, widget.textureText:GetTextWidth() + 40)
    maxWidth = math.max(maxWidth, widget.coordText:GetTextWidth() + 40)
    
    -- Ограничение максимальной ширины
    local newWidth = math.min(MAX_WIDTH, math.max(350, maxWidth))
    
    -- Рассчитываем необходимую высоту
    local newHeight = 8  -- Верхний отступ
        + widget.zoneText:GetTextHeight()
        + 3 + widget.subzoneText:GetTextHeight()
        + 3 + widget.textureText:GetTextHeight()
        + 3 + widget.coordText:GetTextHeight()
        + 8  -- Нижний отступ
    
    -- Применяем новые размеры
    widget.frame:SetDimensions(newWidth, newHeight)
end

-- Функция для получения имени текстуры
local function GetMapTextureName()
    local texture = GetMapTileTexture()
    if texture and texture ~= "" then
        local filename = string.match(texture, "([^/]+)%.dds$")
        return filename or _("unknown")
    end
    return "N/A"
end

-- Функция обновления данных
local function UpdateZoneInfo()
    if not widget or not widget.frame then return end
    
    -- Получение данных
    local zoneName = GetUnitZone("player") or _("unknown")
    local subzoneName = GetPlayerLocationName() or ""
    local x, y = GetMapPlayerPosition("player")
    local textureName = GetMapTextureName()
    
    -- Обновление текста
    widget.zoneText:SetText(zo_strformat("<<1>>: <<2>>", _("zone"), zoneName))
    
    if subzoneName ~= "" then
        widget.subzoneText:SetText(zo_strformat("<<1>>: <<2>>", _("subzone"), subzoneName))
    else
        widget.subzoneText:SetText("")
    end
    
    -- Форматирование координат
    if x == 0 and y == 0 then
        widget.coordText:SetText(zo_strformat("<<1>>: <<2>>", _("coords"), _("unavailable")))
    else
        local xText = string.format("%.2f%%", x * 100)
        local yText = string.format("%.2f%%", y * 100)
        widget.coordText:SetText(zo_strformat("<<1>>: <<2>> | <<3>>: <<4>>", 
            _("x"), xText, _("y"), yText))
    end
    
    -- Отображение имени текстуры
    widget.textureText:SetText(zo_strformat("<<1>>: <<2>>", _("texture"), textureName))
    
    -- Автоматическая подстройка размера окна
    AdjustWindowSize()
end

-- Обработчик изменения состояния интерфейса
local function OnHUDVisibilityChanged()
    if not widget or not widget.frame then return end
    
    local isUIShown = not SCENE_MANAGER:IsShowingBaseScene()
    
    -- Если открыто какое-либо окно интерфейса
    if isUIShown then
        -- Запоминаем состояние только если еще не запомнили
        if wasVisibleBeforeHide == false then
            wasVisibleBeforeHide = not widget.frame:IsHidden()
        end
        
        -- Скрываем виджет если он был видим
        if wasVisibleBeforeHide then
            widget.frame:SetHidden(true)
        end
    else
        -- Восстанавливаем видимость после закрытия окон
        if wasVisibleBeforeHide then
            widget.frame:SetHidden(false)
            wasVisibleBeforeHide = false
        end
    end
end

-- Функция обработки команд
local function ProcessCommand(args)
    local command = string.lower(args or "")
    
    if command == "1" or command == "on" or command == "show" then
        -- Показать окно
        if widget and widget.frame then
            widget.frame:SetHidden(false)
            if ZI_CharSavedVars.lockPosition then
                ZI_GlobalSavedVars.hidden = false
            else
                ZI_CharSavedVars.hidden = false
            end
            d("ZoneInfo: " .. _("window_shown"))
        end
    elseif command == "0" or command == "off" or command == "hide" then
        -- Скрыть окно
        if widget and widget.frame then
            widget.frame:SetHidden(true)
            if ZI_CharSavedVars.lockPosition then
                ZI_GlobalSavedVars.hidden = true
            else
                ZI_CharSavedVars.hidden = true
            end
            d("ZoneInfo: " .. _("window_hidden"))
        end
    elseif command == "toggle" or command == "" then
        -- Переключить видимость
        if widget and widget.frame then
            local newState = not widget.frame:IsHidden()
            widget.frame:SetHidden(newState)
            
            if ZI_CharSavedVars.lockPosition then
                ZI_GlobalSavedVars.hidden = newState
            else
                ZI_CharSavedVars.hidden = newState
            end
            
            d("ZoneInfo: " .. (newState and _("window_hidden") or _("window_shown")))
        end
    elseif command == "lock" then
        -- Фиксация положения
        if widget and widget.lockBtn then
            widget.lockBtn:GetHandler("OnClicked")()
        end
    elseif command == "global" then
        -- Переключить глобальный режим
        if widget and widget.globalBtn then
            widget.globalBtn:GetHandler("OnClicked")()
        end
    elseif command == "reset" then
        -- Сброс позиции
        if widget and widget.frame then
            widget.frame:ClearAnchors()
            widget.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 50)
            -- Обновить сохраненные позиции
            if ZI_CharSavedVars.lockPosition then
                ZI_GlobalSavedVars.x = 50
                ZI_GlobalSavedVars.y = 50
            else
                ZI_CharSavedVars.x = 50
                ZI_CharSavedVars.y = 50
            end
            d("ZoneInfo: " .. _("position_reset"))
        end
    else
        -- Справка по командам
        d(_("commands_title"))
        d(_("toggle_help"))
        d(_("show_help"))
        d(_("hide_help"))
        d(_("lock_help"))
        d(_("global_help"))
        d(_("reset_help"))
    end
end

-- Инициализация аддона
local function OnAddOnLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    
    -- Загрузка сохраненных переменных
    ZI_GlobalSavedVars = ZO_SavedVars:NewAccountWide("ZI_GlobalSavedVars", 1, nil, {
        x = 50,
        y = 50,
        hidden = false
    })
    
    ZI_CharSavedVars = ZO_SavedVars:NewCharacterIdSettings("ZI_CharSavedVars", 1, nil, {
        x = 50,
        y = 50,
        hidden = false,
        lockPosition = false
    })
    
    -- Создание виджета
    widget = CreateZoneInfoWidget()
    
    -- Убедимся, что виджет создан
    if widget and widget.frame then
        -- Применить положение окна
        ApplyPosition(widget.frame)
        
        -- Настроить кнопки
        widget.frame:SetMouseEnabled(not isPositionLocked)
        
        if ZI_CharSavedVars.lockPosition then
            widget.globalBtn:SetNormalTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_down.dds")
        else
            widget.globalBtn:SetNormalTexture("/esoui/art/tutorial/quest_icon_indexicon_alliance_up.dds")
        end
        
        -- Обновление данных
        UpdateZoneInfo()
        
        -- Обновление по таймеру
        EVENT_MANAGER:RegisterForUpdate("ZI_Updater", 200, UpdateZoneInfo)
        
        -- Регистрация событий
        EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ZONE_CHANGED, UpdateZoneInfo)
        EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, function()
            UpdateZoneInfo()
            -- Регистрируем обработчик после полной загрузки интерфейса
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnHUDVisibilityChanged)
            
            -- Также регистрируем обработчик при каждом изменении интерфейса
            EVENT_MANAGER:RegisterForUpdate("ZI_HUDUpdater", 100, OnHUDVisibilityChanged)
        end)
        
        d(_("loaded"))
    else
        d("ZoneInfo: " .. _("failed_create"))
    end
end

-- Регистрация команд
SLASH_COMMANDS["/zi"] = ProcessCommand
SLASH_COMMANDS["/zoneinfo"] = ProcessCommand

-- Регистрация события загрузки
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)